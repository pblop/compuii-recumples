#include <stdio.h>
#include <stdlib.h>

char dia = 31;
char mes = 7;
short ano = 1969;
char nCumples = 30;

char dias[12] = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
char *meses[12] = {"enero", "febrero", "marzo", "abril", "mayo", "junio", "julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre"};

char anoBisiesto()
{
  return ano % 4 == 0;
}

int main()
{
  int mesAnt;
  int anoPre;
  for (int i = 0; i <= nCumples; i++)
  {
    printf("%02d: %02d (%d) de %s (%d) de %04d\n", i, dia, dias[mes - 1], meses[mes - 1], mes, ano);
    dia++;
    // printf("\n\n");
    // printf("\n\tdia incrementado: %d",dia);
    if (mes == 12)
    {
      // printf("\nhola soy diciembre");
      if (dia > 31)
      {
        dia = dia - 31;
        // printf("\ndias me he asao: %d", dia);
        mes = 1;
      }
      else
        dia += dias[mes - 2] - dias[mes - 1];
        // printf("\ndias normales %d", dia);
        mes = 0;
      
    }else
    {
      if (dia >= dias[mes + 1 - 1] + 1)
      {
        // printf("\nNos pasamos de meses.");
        // printf("\ndia = %d - %d", dia, dias[mes + 1 - 1]);
        dia = dia - dias[mes + 1 - 1];
        // printf("= %d", dia);
        mes++;
        // printf("\nmes: %d", mes);
      }
      else
      {
        // printf("\nNo nos pasamos.\ndia = dia + %d - %d",dias[mes - 2], dias[mes - 1]);
        if (mes == 1)
        {
          // printf("\nhola soy enero. No sumo nada porque 31 - 31 es 0");
          // TODO: mirar a ver si esto pasa en mas meses
          // realemtne pasa cuando el mes anterior y este tienen el mismo numero de dias
          // Ej: diciembre-enero, julio-agosto
        } else
        {
          // para que de en febrero tenemos que usar 28 dias, no 29
          if (mes == 2)
          {
            // printf("\nhola soy febrero");
            dia += 31 - 28;
          }else
          {
            dia += dias[mes - 2] - dias[mes - 1];
            // printf("= %d", dia);
          }
      }
       }
    }

    mes++;
    // printf("\n\tmes: %d", mes);
    ano++;
    // printf("\n\tano: %d\n\n", ano);
    if (mes == 1)
      ano++;

    if (anoBisiesto())
      dias[1] = 29;
    else
      dias[1] = 28;
    
  }

  return 0;
}
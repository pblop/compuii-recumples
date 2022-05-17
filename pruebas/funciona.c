#include <stdio.h>
#include <stdlib.h>

char dia = DIA;
char mes = MES;
short ano = ANO;
char nCumples = 30;
int i = 0;

char dias[12] = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
char *meses[12] = {"enero", "febrero", "marzo", "abril", "mayo", "junio", "julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre"};

char anoBisiesto(short a)
{
  return (a + 1) % 4 == 0;
}

void corregirBisiesto()
{
  if (anoBisiesto(ano))
    dias[1] = 29;
  else
    dias[1] = 28;
}

void MostrarFecha()
{
  printf("%02d: %02d de %s de %04d\n", i, dia, meses[mes - 1], ano);
}

// llamamos a esta funcion if(mes == 1 && (dia == 29 || dia == 28))
void MeCagoEnFebrero()
{
  if (i == 30)
  {
    return;
  }
  dia++;
  // printf("dia incrementado: %d\n", dia);
  dia = dia - dias[1];
  // printf("nuevo dia: %d\n", dia);
  mes = 3;
  ano++;
  // printf("ano: %d\n", ano);
  i++;
  // comprobar que esto es cierto tambien para los anos bisiestos
  // que no lo va a ser porque si enero == 28 enotnces el siguiente si puede 
  // ser febrero y dia == 29
  MostrarFecha();
  // printf("i incremenKtado: %d\n", i);
  dia += 29;
  // printf("dia ajustado: %d\n", dia);
  ano++;
  // printf("ano: %d\n", ano);
  // printf("i incrementado: %d\n", i);
}
// despues de llamar a la funcion volvemos al principio del for
// creo que esto nunca va a pasar dentro del while primero.


int main()
{
  while (1)
  {
    if (mes == 12) {
      if (!(dia < dias[0])) break;
    }
    else {
      if (!(dia < dias[mes - 1 + 1])) break;
    }
    MostrarFecha();
    dia++;
    mes++;
    if (mes == 13)
    {
      mes = 1;
      ano++;
    }
    ano++;
    i++;
    if (mes == 1)
      corregirBisiesto();
  }
  for (i = i; i <= nCumples; i++)
  {
    // aqui realmente nos la suda si el ano el bisiesto o no, porque usamos eso para determinar
    // los dias maximos de febrero. En este caso, eso nos importaria en el caso de que enero
    // tuviera un dia alto, pero esa queda solucionado con MeCagoEnFebrero.

    // ahora le meto me cago en febrero
    MostrarFecha();
    if (mes == 1 && (dia == 28 || dia == 29))
    {
      // printf("\nhola soy especial\n");
      corregirBisiesto();
      if (anoBisiesto(ano))
      {
        // printf("%d es bisiesto\n", ano + 1);
        if (dia != 28)
        {
          // printf("dia es 29\n");
          MeCagoEnFebrero();
          dia++; // el dia += 29 de la funcion no funciona para bisiestos
          if (dia > 31)
          {
            dia = 1;
            mes = 4;
          }
          
        } else
        { // se incrementa como en el bucle
          dia++;
          mes++;
          ano++;
        }
        
      }
      else if(!(anoBisiesto(ano))){
        // printf("no es bisiesto\n");
        MeCagoEnFebrero();
      }

    } else
    {
      //funciona.c
      dia++;
      // printf("\n\n");
      // printf("\n\tdia incrementado: %d\n",dia);
      if (mes == 12)
      {
        // printf("\nhola soy diciembre");
        if (dia > 31)
        {
          dia = dia - 31;
          // printf("\ndias me he asao: %d", dia);
          mes = 1;
          ano++;
        }
        else
        {
          dia += dias[mes - 2] - dias[mes - 1];
          // printf("\ndias normales %d", dia);
          mes = 0;

        }
      }else
      {
        if (dia >= dias[mes + 1 - 1] + 1)
        {
          if (mes == 3) // anterior a febrero
          {
            if (anoBisiesto(ano - 1))
              {
                // printf("a\n");
                dia += 29 - 31;
              } else 
              {
                // printf("b\n");
                dia += 28 - 31;
                // printf("dia: %d\n", dia);
              }

              if (dia > 31)
              {
                dia = dia - dias[mes + 1 - 1];
                mes++;
              }
          } else
          {
            // printf("\nNos pasamos de meses.");
            // printf("\ndia = %d - %d", dia, dias[mes + 1 - 1]);
            dia = dia - dias[mes + 1 - 1];
            // printf("= %d\n", dia);
            mes++;
            // printf("\nmes: %d\n", mes);
          }
          
        }
        else
        {
          // printf("\nNo nos pasamos.\ndia = dia + %d - %d\n",dias[mes - 2], dias[mes - 1]);
          if (mes == 1)
          {
            // printf("\nhola soy enero. No sumo nada porque 31 - 31 es 0\n");
            // TODO: mirar a ver si esto pasa en mas meses
            // realemtne pasa cuando el mes anterior y este tienen el mismo numero de dias
            // Ej: diciembre-enero, julio-agosto
          } else
          {
            // para que de en febrero tenemos que usar 28 dias, no 29
            if (mes == 2)
            {
              // printf("\nhola soy febrero\n");
              if (anoBisiesto(ano))
              {
                // printf("a\n");
                dia += 31 - 29;
              } else 
              {
                // printf("b\n");
                dia += 31 - 28;
                // printf("dia: %d\n", dia);
              }

              if (dia > 31)
              {
                dia = dia - 31;
                mes = 3;
              }
              
            }else
            {
              dia += dias[mes - 2] - dias[mes - 1];
              // printf("= %d\n", dia);
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

      if (anoBisiesto(ano - 1))
        dias[1] = 29;
      else
        dias[1] = 28;
    }
  }

  return 0;
}
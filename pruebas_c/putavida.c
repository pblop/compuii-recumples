#include <stdio.h>
#define DIA 31
#define MES 7
#define ANO 1969

char dia = DIA;
char mes = MES;
short ano = ANO;
char nCumples = 30;

char dias[12] = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
char *meses[12] = {"enero", "febrero", "marzo", "abril", "mayo", "junio", "julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre"};

char anoBisiesto()
{
  return ano % 4 == 0;
}

void actualizarBisiesto()
{
  if (anoBisiesto())
    dias[1] = 29;
  else
    dias[1] = 28;
}

void corregirMes()
{
    if (mes > 12)
    {
        mes = 1;
        ano++;
        actualizarBisiesto();
    }
    
}

int main(void)
{
    dia = DIA;
    mes = MES;
    ano = ANO;
    int excepcion = 0;
    for (int i = 0; i <= nCumples; i++)
  {

    printf("%02d: %02d (%d) de %s de %04d\n", i, dia, dias[mes - 1], meses[mes - 1], ano);
    
    ano++;
    actualizarBisiesto();

    if (excepcion)
    {
        mes--;
        excepcion = 0;
    }
    
    if (mes == 1 && dia > dias[mes - 1 + 1])
    {
        excepcion = 1;
    } 

    mes++;
    // printf("\n%d\n", mes);
    corregirMes();
    dia = DIA + i + 1;
    if (mes != 12 && dia > dias[mes - 1])
    {
        if (dia == dias[mes - 1] + 1)
        {
            dia -= dias[mes - 1];
            mes++;
            corregirMes();
        } else
        {
            dia -= dias[mes - 1];
        }

    } else if (dia > 31)
    {
        dia -= 31;
        ano++;
        actualizarBisiesto();
        mes = 2;
    }
    
  }
    return 0;
}
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

void corregirMes()
{
  if (mes > 12)
  {
    mes = 1;
    ano++;
  }
}

void corregirDia()
{
  if (anoBisiesto())
    dias[1] = 29;
  else
    dias[1] = 28;

  if (dia > dias[mes - 1])
  {
    dia = dia - dias[mes - 1];
    mes++;
    corregirMes();
  }
}

int main()
{
  int mesAnt;
  int anoPre;
  for (int i = 0; i <= nCumples; i++)
  {
    printf("%02d: %02d (%d) de %s (%d) de %04d\n", i, dia, dias[mes - 1], meses[mes - 1], mes, ano);
    dia++;
    if (dia >= dias[mes + 1 - 1] + 1)
    {
      dia = dia - dias[mes + 1 - 1];
      mes++;
      corregirMes();
    }
    else
      dia += dias[mes - 1] - dias[mes - 2];

    mes++;
    corregirMes();
    ano++;
    if (mes == 1)
      ano++;

    // corregirDia();
  }

  return 0;
}
#include <stdio.h>
char dia = 31;
char mes = 7;
short ano = 1969;
char nCumples = 10;

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
  for (int i = 0; i < nCumples; i++)
  {
    printf("%02d: %02d de %s de %04d\n", i, dia, meses[mes - 1], ano);
    ano++;
    mes++;
    corregirMes();

    corregirDia();
    dia++;

    corregirDia();
  }

  return 0;
}
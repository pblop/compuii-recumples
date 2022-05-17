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

void febreroDaPorCulo()
{
  
}

int main()
{
  int mesAnt;
  int anoPre;
  for (int i = 0; i <= nCumples; i++)
  {
    printf("%02d: %02d (%d) de %s de %04d\n", i, dia, dias[mes - 1], meses[mes - 1], ano);
    ano++;
    anoPre = ano;
    mes++;
    mesAnt = mes;
    corregirMes();

    corregirDia();
    if (anoPre == ano)
    {
      dia += 1 - (dias[mes - 2] - dias[mes - 1]);
      // printf("%d - %d = %d, %d\n", dias[mes - 2], dias[mes - 1], dias[mesAnt - 2] - dias[mes - 1], dia);
    }

    corregirDia();
  }

  return 0;
}
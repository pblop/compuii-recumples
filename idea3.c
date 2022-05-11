#include <stdio.h>
#define DIA 10
#define MES 6
#define ANO 1980

int timestamp = 0;
char nCumples = 10;

char dias[12] = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
char *meses[12] = {"enero", "febrero", "marzo", "abril", "mayo", "junio", "julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre"};

char anoBisiesto(ano)
{
  return ano % 4 == 0;
}

void actualizarBisiesto(ano)
{
  if (anoBisiesto(ano))
    dias[1] = 29;
  else
    dias[1] = 28;
}

int main()
{
  for (int i = 1920; i < ANO; i++)
  {
    timestamp += 365;
    if (anoBisiesto(i))
      timestamp += 1;
  }
  for (int i = 1; i <= MES; i++)
  {
    if (i == 2)
      actualizarBisiesto(ANO);
    timestamp += dias[i];
  }
  timestamp += DIA;
  printf("%d\n", timestamp);

  return 0;
}
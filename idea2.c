#include <stdio.h>
#define DIA 29
#define MES 1
#define ANO 1940

char dia = DIA;
char mes = MES;
short ano = ANO;
char nCumples = 25;

char dias[12] = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
char *meses[12] = {"enero", "febrero", "marzo", "abril", "mayo", "junio", "julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre"};

char anoBisiesto()
{
  return ano % 4 == 0;
}

void corregirMes()
{
  while (mes > 12)
  {
    mes -= 12;
    ano++;
  }
}

void actualizarBisiesto()
{
  if (anoBisiesto())
    dias[1] = 29;
  else
    dias[1] = 28;
}

void corregirDia()
{
  while (1)
  {
    actualizarBisiesto();
    if (!(dia > dias[mes - 1]))
      break;

    dia = dia - dias[mes - 1];
    mes++;
    corregirMes();
  }
}

int main()
{
  for (int i = 0; i <= nCumples; i++)
  {
    dia = DIA;
    mes = MES;
    ano = ANO;

    ano += i;
    mes += i;
    corregirMes();

    corregirDia();
    dia += i;

    corregirDia();
    printf("%02d: %02d (%d) de %s (%d) de %04d\n", i, dia, dias[mes - 1], meses[mes - 1], mes, ano);
  }

  return 0;
}
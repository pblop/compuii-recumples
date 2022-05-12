#include <stdio.h>

int DIA, MES, ANO;

char dia, mes;
short ano;
char nCumples = 30;

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
  scanf("%d %d %d", &DIA, &MES, &ANO);

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
    printf("%02d: %02d (%d) de %s de %04d\n", i, dia, dias[mes - 1], meses[mes - 1], ano);
  }

  return 0;
}

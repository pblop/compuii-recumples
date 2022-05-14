#include <stdio.h>

int DIA, MES, ANO, i;

char dia, mes;
short ano;
char nCumples = 30;

char dias[12] = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
char *meses[12] = {"enero", "febrero", "marzo", "abril", "mayo", "junio", "julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre"};

void corregirDia()
{
  while (1)
  {
    if (ano % 4 == 0)
      dias[1] = 29;
    else
      dias[1] = 28;

    if (dia <= dias[mes-1])
      break;

    dia -= dias[mes-1];
    mes++;
    
    while (mes > 12)
    {
      mes -= 12;
      ano++;
    }
  }
}


int main()
{
  scanf("%d %d %d", &DIA, &MES, &ANO);

  for (i = 0; i <= nCumples; i++)
  {
    dia = DIA;
    mes = MES;
    ano = ANO;


    corregirDia();
    dia += i;
    corregirDia();
    printf("%02d: %d de %s de %04d\n", i, dia, meses[mes - 1], ano);


    MES++;
    ANO++;
    if (MES > 12)
    {
      MES -= 12;
      ANO++;
    }
  }
}

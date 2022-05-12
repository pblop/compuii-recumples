#include <stdio.h>
#include <stdlib.h>

char dia = 17;
char mes = 4;
short ano = 1920;
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

// llamamos a esta funcion if(mes == 1 && (dia == 29 || dia == 28))
void MeCagoEnFebrero()
{
  dia++;
  dia = dia - dias[1];
  mes = 3;
  ano++;
  // comprobar que esto es cierto tambien para los anos bisiestos
  // que no lo va a ser porque si enero == 28 enotnces el siguiente si puede 
  // ser febrero y dia == 29
  MostrarFecha();
  i++;
  dia += 29;
  ano++;
  MostrarFecha();
  i++;
}
// despues de llamar a la funcion volvemos al principio del for
// creo que esto nunca va a pasar dentro del while primero.

void MostrarFecha()
{
  printf("%02d: %02d (%d) de %s (%d) de %04d\n", i, dia, dias[mes - 1], meses[mes - 1], mes, ano);
}

int main()
{
  for (i = 0; i <= nCumples; i++)
  {
    // aqui realmente nos la suda si el ano el bisiesto o no, porque usamos eso para determinar
    // los dias maximos de febrero. En este caso, eso nos importaria en el caso de que enero
    // tuviera un dia alto, pero esa queda solucionado con MeCagoEnFebrero.

    // ahora le meto me cago en febrero
    while (dia < dias[mes - 1 + 1])
    {
      MostrarFecha();
      if (mes == 1 && (dia == 28 || dia == 29))
      {
        corregirBisiesto();
        if (anoBisiesto(ano))
          if (dia != 28)
            MeCagoEnFebrero();
          
        else  
          MeCagoEnFebrero();
      } else
      {
        dia++;
        mes++;
        if (mes == 13)
        {
          mes = 1;
          ano++;
        }
        ano++;
        i++;
      }
    }
    

    // algoritmo tope chungo de funciona.c
  }

  return 0;
}
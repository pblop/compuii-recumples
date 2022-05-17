#include <stdio.h>

int longitud_meses[] = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
char *meses[12] = {"enero", "febrero", "marzo", "abril", "mayo", "junio", "julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre"};

void corrige_fecha(int *d, int *m, int *a);
void recumple(int dia, int mes, int ano, int n);

int main()
{
    // Variables
    // el día y el mes empiezan en 0
    int dia = 28, mes = 1, ano = 1920, n;   // 29-2-1920
    scanf("%d %d %d", &dia, &mes, &ano);
    dia--; mes--;

    for (n = 0; n <= 30; n++)
      recumple(dia, mes, ano, n);
}


void corrige_fecha(int *d, int *m, int *a)
{
    int bisiesto_importa;

    // Pequeña comprobación de mes inicial que se debería poner
    // en una función aparte porque se usa más de una vez:
    if (*m >= 12)
    {
        *a += *m / 12; 
        *m = *m % 12;
    }

    // big boi
    bisiesto_importa = (*m == 1) * (*a % 4 == 0); 
    while (*d >= (longitud_meses[*m] + bisiesto_importa))
    {
        *d -= (longitud_meses[*m] + bisiesto_importa);
        (*m)++;

        if (*m >= 12)
        {
            *a += *m / 12; 
            *m = *m % 12;
        }
    }
}


void recumple(int dia, int mes, int ano, int n)
{
    // Paso 1 
    ano += n;
    corrige_fecha(&dia, &mes, &ano);    // comprobación rara, ilegal incluso
                                        // corrige el 29-02-<año no bisiesto>
                                        //          a 01-03-<año no bisiesto>
    //printf("paso 1: %d %d %d\n", dia + 1, mes + 1, ano);

    // Paso 2
    mes += n;
    //printf("paso 2: %d %d %d\n", dia + 1, mes + 1, ano);

    // Paso 3
    corrige_fecha(&dia, &mes, &ano);
    //printf("paso 3: %d %d %d\n", dia + 1, mes + 1, ano);

    // Paso 4
    dia += n;
    corrige_fecha(&dia, &mes, &ano);

    printf("%02d: %d de %s de %d\n", n, dia + 1, meses[mes], ano);
}



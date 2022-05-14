#!/usr/bin/env bash

gcc tools/comprobacion.c -o tools/comprobacion
gcc pruebas_c/recumple.c -o pruebas_c/recumple

dias=(31 28 31 30 31 30 31 31 30 31 30 31)

for ANO in {1920..2050}
do
  for MES in {1..12}
  do
    #if [ $(($ANO % 4)) -eq 0 ]
    #then
    #  dias[1]=29
    #else
    #  dias[1]=28
    #fi

    for (( DIA=1; DIA<=dias[$MES-1]; DIA++ ))
    do
      printf "Comprobando: $DIA/$MES/$ANO..."
      salidacorrecta=$(echo "$DIA $MES $ANO" | tools/comprobacion)
      salida=$(echo "$DIA $MES $ANO" | pruebas_c/recumple)

      if [ "$salidacorrecta" == "$salida" ]
      then
        printf "✅\n"
      else
        printf "❌\n"
        printf "Esperaba:\n"
        printf "$salidacorrecta\n"
        printf "==========================\n"
        printf "Encontrado:\n"
        printf "$salida\n"
        printf "==========================\n"
        printf "Diferencia:\n"
        printf "$(diff <(printf "$salidacorrecta\n") <(printf "$salida\n"))\n"
        #exit
      fi
    done
  done
done


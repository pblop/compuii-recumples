#!/usr/bin/env bash

gcc tools/comprobacion.c -o tools/comprobacion

dias=(31 28 31 30 31 30 31 31 30 31 30 31)

for ANO in {1920..2050}
do
  for MES in {1..12}
  do
    if [ $(($ANO % 4)) -eq 0 ]
    then
      dias[1]=29
    else
      dias[1]=28
    fi

    for (( DIA=1; DIA<=dias[$MES-1]; DIA++ ))
    do
      printf "Comprobando: $DIA/$MES/$ANO..."
      salidacorrecta=$(echo "$DIA $MES $ANO" > tools/comprobacion)
      
      

      salida=$()
    done
  done
done

echo ""


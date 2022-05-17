#!/usr/bin/env bash

gcc tools/comprobacion.c -o tools/comprobacion

function comprobar()
{
  DIA=$1
  MES=$2
  ANO=$3
  printf "Comprobando: $DIA/$MES/$ANO..."
  salidacorrecta=$(echo "$DIA $MES $ANO" | tools/comprobacion)
  
  #make DIA=$DIA MES=$MES ANO=$ANO
  salida=$(make run --silent DIA=$DIA MES=$MES ANO=$ANO 2>/dev/null | grep '^[0-9]')

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
    exit
  fi
}

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
      comprobar $DIA $MES $ANO
    done
  done
done

echo ""


#!/usr/bin/env bash

gcc tools/comprobacion.c -o tools/comprobacion
rm -r temp error

function comprobar()
{
  out=""
  padre=$(pwd)
  # Continuar si no ha habido ningún error en el programa (el archivo error se ha creado)
  if [ ! -e "${padre}/error" ]
  then
    DIA=$1
    MES=$2
    ANO=$3

    out+=$(printf "Comprobando: $DIA/$MES/$ANO...")
    salidacorrecta=$(echo "$DIA $MES $ANO" | tools/comprobacion)

    carpeta="temp/${DIA}_${MES}_${ANO}"
    mkdir -p "$carpeta"

    cp -t "$carpeta" recumples.asm Makefile
    cd $carpeta
    
    salida=$(make run --silent DIA=$DIA MES=$MES ANO=$ANO 2>/dev/null | grep '^[0-9]')

    if [ "$salidacorrecta" == "$salida" ]
    then
      out+=$(printf "✅\n")
    else
      out+=$(printf "❌\n")
      out+=$(printf "Esperaba:\n")
      out+=$(printf "$salidacorrecta\n")
      out+=$(printf "==========================\n")
      out+=$(printf "Encontrado:\n")
      out+=$(printf "$salida\n")
      out+=$(printf "==========================\n")
      out+=$(printf "Diferencia:\n")
      out+=$(printf "$(diff <(printf "$salidacorrecta\n") <(printf "$salida\n"))\n")
      
      touch "${padre}/error"
    fi

    cd $padre
    rm -r $carpeta
  fi

  echo $out
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
      if [ -e "error" ]
      then
        exit
      fi

      comprobar $DIA $MES $ANO &
    done
  done
done

echo ""


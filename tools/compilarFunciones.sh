#!/usr/bin/env bash

gcc pruebas_c/funciona.c -D DIA=$1 -D MES=$2 -D ANO=$3 -o pruebas_c/funciona

pruebas_c/funciona

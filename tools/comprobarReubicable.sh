#!/usr/bin/env bash

# recumples.rel should already exist (required by makefile)
aslink -s -b _CODE=0x100 "${1}-100.s19" "${1}.rel" > /dev/null
aslink -s -b _CODE=0x1234 "${1}-1234.s19" "${1}.rel" > /dev/null

B100=$(./muestraBytes.sh "${1}-100.s19")
B1234=$(./muestraBytes.sh "${1}-1234.s19")

DIFF=$(diff <(echo $B100) <(echo $B1234))

if [ $? -eq 0 ]; then
  echo "✅ Reubicable"
else
  echo "✅ No reubicable"
  echo "$DIFF"
fi


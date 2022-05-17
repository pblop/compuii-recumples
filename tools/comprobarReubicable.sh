#!/usr/bin/env bash

# recumples.rel should already exist (required by makefile)
aslink -s -b _CODE=0x100 "${1}-100.s19" "${1}.rel" > /dev/null
aslink -s -b _CODE=0x1234 "${1}-1234.s19" "${1}.rel" > /dev/null

B100=$(./tools/muestraBytes.sh "${1}-100.s19")
B1234=$(./tools/muestraBytes.sh "${1}-1234.s19")

# remove the last 4 chars of B100 and B1234 (they're the program starting address, and it will always be different)
# if we've moved the code. this doesn't matter for checking if the code is relocatable.
B100=${B100::${#B100}-4}
B1234=${B1234::${#B1234}-4}

DIFF=$(diff <(echo $B100) <(echo $B1234))

if [ $? -eq 0 ]; then
  echo "✅ Reubicable"
else
  echo "❌ No reubicable"
  echo "$DIFF"
fi


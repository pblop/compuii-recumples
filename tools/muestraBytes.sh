#/bin/bash

declare -a BYTES
BYTES=""
while read
do
  B=${REPLY:4} # first four characters are type and count.
  B=${B:4} # remove the 4 byte memory address
  B=${B::${#B}-2} # last 2 bytes are checksum
  B=${B// } # remove spaces
  BYTES+=$B
done <<< $(cat $1 | grep "^S1")

echo $BYTES


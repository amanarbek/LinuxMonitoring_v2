#!/usr/bin/env bash

source check_params
source generator

check_params $@
###
elem=$2
generator $elem $3
FOLDERS=(${ITEMS[@]})
###
echo ----------
elem=$4
string=(${5//.[a-zA-Z]*/})
tail=(${5//[a-zA-Z]*\./.})
generator $elem $string
FILES=(${ITEMS[@]})
###

if [[ ! -d $1 ]];then
  mkdir $1
fi

DATE=$(date +"%d.%m.%Y")

FREE_GB=$( expr $( df -BG / | tail -1 | awk '{print $4}') : '\([0-9]*\)')

for i in ${FOLDERS[@]}; do
  mkdir -m 777 $1/$i
  for a in ${FILES[@]}; do
    if [[ $FREE_GB -eq 1 ]]; then
      echo not enough memory!
      exit 0
    fi
    dd if=/dev/zero of="$1/$i/${a}_${DATE}$tail"  bs=1K  count=`echo "$6" | sed 's/kb//'`
    echo $1/$i/${a}_${DATE}${tail} - ${DATE} - ${6} >> logs
    FREE_GB=$( df -BG / | tail -1 | awk '{print substr($4, 1, length($4)-1)}' )
  done
done

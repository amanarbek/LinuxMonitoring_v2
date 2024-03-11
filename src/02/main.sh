#!/usr/bin/env bash

source check_params
source generator

check_params $@

START=$(date +%s%N)
START_TIME=$(date +"%T")
DATE=$(date +"%d.%m.%Y")

FREE_GB=$( expr $( df -BG / | tail -1 | awk '{print $4}') : '\([0-9]*\)')

ROOT=$(find / -maxdepth 2 -type d -perm /a=w 2> /dev/null | grep -ve "\/s\?bin")
ROOT_ARR=(${ROOT})
ROOT_LEN=$((${#ROOT_ARR[@]}-1))

elem=$(($RANDOM % 100 + 1))
generator $elem $1
FOLDERS=(${ITEMS[@]})
FOLDS=$elem

string=(${2//.[a-zA-Z]*/})
tail=(${2//[a-zA-Z]*\./.})
elem=300
generator $elem $string
FILES=(${ITEMS[@]})
CODE_EXIT=0
for ((i = 0; i < $FOLDS; ++i)); do
  DIR=${ROOT_ARR[$(($RANDOM % ${ROOT_LEN} + 0))]}/${FOLDERS[i]}_$DATE
  mkdir -m 777 $DIR
  RAN_FILES=$(($RANDOM % 200 + 100))
  COUNT_FILES=0
  for a in ${FILES[@]}; do
    if [[ $COUNT_FILES -eq $RAN_FILES ]]; then
      break
    fi
    if [[ $FREE_GB -eq 1 ]]; then
      echo not enough memory!
      CODE_EXIT=1
      break
    fi
    dd if=/dev/zero of="$DIR/${a}_${DATE}${tail}"  bs=1M  count=`echo "$3" | sed 's/Mb//'`
    echo $DIR/${a}_${DATE}${tail} - ${DATE} - ${3} >> logs
    FREE_GB=$( df -BG / | tail -1 | awk '{print substr($4, 1, length($4)-1)}' )
    ((++COUNT_FILES))
  done
  if [[ $CODE_EXIT -eq 1 ]]; then
    break
  fi
done

REPORT=logs
END=$(date +%s%N)
END_TIME=$(date +"%T")
DIFF=$((($END - $START)/1000000))
echo "It took $DIFF milliseconds"
echo "Started: $DATE $START_TIME"
echo "Started: $DATE $START_TIME" >> $REPORT
echo "Completed: $DATE $END_TIME"
echo "Completed: $DATE $END_TIME" >> $REPORT 
START_TIME=$(date -u -d "$START_TIME" +"%s")
END_TIME=$(date -u -d "$END_TIME" +"%s")
date -u -d "0 $END_TIME sec - $START_TIME sec" +"%H:%M:%S"
date -u -d "0 $END_TIME sec - $START_TIME sec" +"%H:%M:%S" >> $REPORT 
if [[ $CODE_EXIT -eq 1 ]]; then
  exit 1
fi

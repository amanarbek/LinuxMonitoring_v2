#!/usr/bin/env bash

STDERR='/dev/stderr'

source check_params

check_params $@

if [[ $1 -eq 1 ]]; then
  ARR_LOGS=$(cat ../02/logs | grep -o '^\/\S*\/' | sort | uniq)
  rm -rf $ARR_LOGS
  rm ../02/logs
elif [[ $1 -eq 2 ]]; then
  pattern='^(0[1-9]|1[0-2])\/(0[1-9]|1[0-9]|2[0-9]|3[0-1])\/(19[7-9][0-9]|2[0-9]{3})\s(0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]$'

  echo "Enter starting date and time (e.g. Month/Day/Year 00:00)"
  read start
  if [[ ! $start =~ $pattern ]]; then
    echo "Error! (e.g. Month/Day/Year 00:00)" > $STDERR
    echo "$start"
    exit 1
  fi

  echo "Enter ending date and time (e.g. Month/Day/Year 00:00)"
  read end
  if [[ ! $end =~ $pattern ]]; then
    echo "Error! (e.g. Month/Day/Year 00:00)" > $STDERR
    exit 1
  fi

  start_epoch=$(date -d "$start" +"%s")
  end_epoch=$(date -d "$end" +"%s")

  ARR_DEL=($(find / -maxdepth 3 -type d -perm 777 -exec stat -c'%n %Z' {} +))
  ARR_LEN=${#ARR_DEL[@]}
  
  for ((i = 0; i < $ARR_LEN; i+=2)); do
    if [[ ${ARR_DEL[i+1]} -lt $end_epoch ]] && [[ ${ARR_DEL[i+1]} -gt $start_epoch ]]; then
      rm -rf ${ARR_DEL[i]}
    fi
  done
  
elif [[ $1 -eq 3 ]]; then
  mask='[a-z]*_[0-9][0-9].[0-9][0-9].[0-9][0-9][0-9][0-9]'
  find / -type d -name $mask -exec rm -rf {} + 
fi

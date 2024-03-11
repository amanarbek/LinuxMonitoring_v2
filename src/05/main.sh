#!/bin/bash

PARAMETRS='^[1-4]$'
RESPONSE_CODE='20[01]'
LOGS_PATH='../04/logs'
STDERR='/dev/stderr'

if [[ ! $# -eq 1 ]] && [[ ! $1 =~ $PARAMETRS ]]; then
  echo "The script runs with 1 parameter, which has a value of 1, 2, 3 or 4.
1. All entries sorted by response code
2. All unique IPs found in the entries
3. All requests with errors (response code - 4xx or 5xxx)
4. All unique IPs found among the erroneous requests" > $STDERR
  exit 0
fi

case $1 in
  "1")
    cat $LOGS_PATH/*.log | sort -k8
    ;;
  "2")
    cat $LOGS_PATH/*.log | awk '{print$1}'| uniq
    ;;
  "3")
    cat $LOGS_PATH/*.log | grep -ve $RESPONSE_CODE
    ;;
  "4")
    cat $LOGS_PATH/*.log | grep -ve $RESPONSE_CODE | awk '{print$1}' | uniq
    ;;
esac

exit 0


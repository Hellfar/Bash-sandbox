#!/bin/bash

if [ -n "$1" ]; then
  PATTERN="$1"
else
  PATTERN=".*"
fi

if [ -n "$2" ]; then
  FILE="$2"
else
  FILE="conf.ini"
fi

GROUP="default"

cat $FILE | while read line; do
  case "$line" in
    "")
      ;;
    "`echo "$line" | grep '\[.*\]'`")
      GROUP=${line:1: -1}
      ;;
    "`echo "$line" | grep '^#'`")
      ;;
    *)
      echo "$GROUP/$line"
      ;;
  esac
done | grep "$PATTERN"

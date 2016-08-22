#!/bin/bash

PATTERN="$1"
FILE="$2"

GROUP="default"

cat $FILE | while read line; do
  case "$line" in
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

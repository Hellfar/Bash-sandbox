#!/bin/bash

if [ -z "$1" ]
then
	export list="wordlist_en.txt"
else
	export list="$1"
fi

let t=`let MAX=\`cat $list | wc -l\`;expr \`cat /dev/urandom | tr -dc 0-9 | fold -w${#MAX} | head -1 | sed 's/^0*//;'\` % $MAX + 1`;cat wordlist_en.txt | sed -n "$t,$t p"

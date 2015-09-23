#!/bin/bash

let t=`let MAX=\`cat wordlist_en.txt | wc -l\`;expr \`cat /dev/urandom | tr -dc 0-9 | fold -w${#MAX} | head -1 | sed 's/^0*//;'\` % $MAX + 1`;cat wordlist_en.txt | sed -n "$t,$t p"

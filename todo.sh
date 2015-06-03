#! /bin/bash

export DIALOG=${DIALOG=dialog}
if [ -n "$@" ]
then
	export TODO="$@"
else
	export TODO="TODO"
fi

fichtempList=`tempfile 2> /dev/null` || fichtempList=/tmp/test$$
trap "rm -f $fichtempList" 0 1 2 5 15

while [ "true" ]
do
	export b=""

	export i=1
	export params=`cat "$TODO" | sed -e '$a\' | while read line
	do
		export status=\`echo "$line" | sed -e 's/\\s.*$//'\`
		export descr=\`echo "$line" | sed -e 's/^[-Dx]\\s//'\`

		echo -en "\\"$i\\" \\"$descr\\" "

		if [ "$status" == "-" ]
		then
			echo -en "off "
		else
			echo -en "on "
		fi

		i=\`expr "$i" + 1\`
	done`

	export lines="`tput lines`"
	export cols="`expr \`tput cols\` - 20`"
	export entries="`expr \`cat \"$TODO\" | sed -e '$a\' | wc -l\` + 2`"
	if [ $entries -gt $lines ]
	then
		entries="`expr $lines - 10`"
	fi
	echo "$params" | xargs $DIALOG --backtitle "TODO LIST SOFTWARE" \
		--title "TODO" --clear \
			--checklist "Here is your current tasks:" `expr $lines - 5` $cols $entries \
			"add" "Add an Item to this list." off \
			"rm" "remove the selected choices." off 2> $fichtempList

	valretList=$?
	export responses=`cat $fichtempList | tr ' ' '\n'`
	case $valretList in
		0)
			export choices=`echo "$responses" | grep -v "rm" | grep -v "add"`

			if [ -n "`echo $responses | grep \"rm\"`" ]
			then
				sed -i -e "`echo -n "$choices" | tr '\n' ' ' | sed -e 's/ /d;/g' -e 's/$/d/'`" $TODO

				b="true"
			else
	#ticking the selected ones.
				echo "$choices" | xargs -I{} bash -c "sed -ie '{}s/^-/x/' $TODO"
	#unticking those are not selected.
				cat <(nl $TODO | grep -oP "^\s*\d+" | tr -d ' ') <(echo "$choices") | sort | uniq -u | xargs -I{} bash -c "sed -ie '{}s/^x/-/' $TODO"
			fi

			if [ -n "`echo $responses | grep \"add\"`" ]
			then
				fichtempNewItem=`tempfile 2> /dev/null` || fichtempNewItem=/tmp/test$$
				trap "rm -f $fichtempNewItem" 0 1 2 5 15

				$DIALOG --backtitle "TODO LIST SOFTWARE" \
				--title "Add an item" --clear \
					--inputbox "Fill the field below with descreption:" 8 $cols 2> $fichtempNewItem

				valretNewItem=$?
				export newItem=`cat $fichtempNewItem`
				case $valretNewItem in
					0)
						echo "- $newItem" >> $TODO

						b="true"
						;;
					1)
						echo "Aborded"
						;;
					123)
						echo "Aborded"
						;;
					124)
						echo "Escaped"
						;;
					255)
						echo "Escaped"
						;;
				esac
			fi
			;;
		1)
			echo "Aborded"
			;;
		123)
			echo "Aborded"
			;;
		124)
			echo "Escaped"
			;;
		255)
			echo "Escaped"
			;;
	esac
	if [ "$b" != "true" ]
	then
		break;
	fi
done
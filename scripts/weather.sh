#!/bin/bash
FILE=/home/shpaq/.EPWA.txt

case $1 in
	"")
		echo "Usage: temp, pres, cond"
		exit 0
		;;

	"temp")
		awk -F\( '/Temp/ {print $2}' $FILE | sed -e 's/ C)//g' 
		exit 0
		;;

	"pres")
		awk -F\( '/Pressure/ {print $3}' $FILE | sed -e 's/)//g'
		exit 0
		;;

	"cond")
		sed -n 5p $FILE | awk -F\: '{print $2}' | sed -e 's/^ //g'
		exit 0
		;;
esac

#!/bin/bash
# mpc2mp3
#
# mpc to mp3 converter
#
# In order to work, mpc2mp3 uses 'mpcdec' to convert mpc file into wav format, and then 'lame' to convert wav into mp3.
# The default quality of the resulting mp3 file is high, to modify this, just change the 'lame' flags ($LAME_FLAGS). This can be usefull if you want to save some time.
#
#
# Tested in:
# OS: Linux Mint 10 Julia
# bash: version 4.1.5(1)-release (x86_64-pc-linux-gnu)
# mpcdec: Musepack (MPC) decoder v1.0.0 (C) 2006-2009 MDT
# lame: 64bits version 3.98.4 (http://www.mp3dev.org/)
#  
# Author: Lucas B. Pinheiro
# Contact: pinheiro.lucas@gmail.com
#
# january 25th, 2012
#############################################################

VERSION="0.1"
MSG_HELP="Version $VERSION 
MPC -> MP3 converter

Usage: $(basename $0) [OPTIONS]

OPTIONS
-f | --file   \t Input file (must have 'mpc' extension)
-a | --all    \t Converts all mpc files in the current folder
-v | --version\t Displays this script version
-h | --help   \t Shows this help msg :)
"

MSG_WRONG_FILE="input file must have 'mpc' extension"
MSG_MPCDEC_NOT_FOUND="This script requires 'mpcdec' - please install it in order to continue"
MSG_MPCDEC_NOT_FOUND_HELP="This script requires the program'mpcdec', which is not installed"
MSG_LAME_NOT_FOUND="This script requires 'lame' - please install it in order to continue"
MSG_LAME_NOT_FOUND_HELP="This script requires the program 'lame', which is not installed"
MSG_EMPTY_FILE_NAME="empty file name"
MSG_USE_FILE_OPTION="use option '-f' or '--file' to enter a valid file name"
MSG_INVALID_OPTION="invalid option"
MSG_FILE_NOT_FOUND="file not found"

ERR_MPCDEC_NOT_FOUND=1
ERR_LAME_NOT_FOUND=2
ERR_EMPTY_FILE_NAME=3
ERR_NOT_MPC_EXTENSION=4
ERR_INVALID_OPTION=5
ERR_OPTION_MISSING=6
ERR_MPCDEC_PROBLEM=7
ERR_LAME_PROBLEM=8
ERR_FILE_NOT_FOUND=9

SMOOTH_RUN=0
LOOP=0
LAME_FLAGS="-h -V 0 --quiet"

file=

command -v mpcdec &>/dev/null || { mpcdec_status=1; }
command -v lame &>/dev/null || { lame_status=1; } 

shopt -s nocasematch

while test -n "$1"
do
	case "$1" in
		-f|--file)
			shift
			file="$1"
			test -z "$file" && echo "$MSG_EMPTY_FILE_NAME" && exit $ERR_EMPTY_FILE_NAME
			test ! -f "$file" && echo "$MSG_FILE_NOT_FOUND" && exit $ERR_FILE_NOT_FOUND
			[[ ${file##*.} =~ \.(mpc) ]] && echo "$MSG_WRONG_FILE" && exit $ERR_NOT_MPC_EXTENSION
		;;
		-a|--all)
			LOOP=1
		;;
		-v|--version)
			echo "$VERSION" && exit $SMOOTH_RUN
		;;
		-h|--help)
			echo -e "$MSG_HELP" 
			if [[ $mpcdec_status == 1 || $lame_status == 1 ]]
			then
				echo "WARNING"
				[[ $mpcdec_status == 1 ]] && echo "$MSG_MPCDEC_NOT_FOUND_HELP"
				[[ $lame_status == 1 ]] && echo "$MSG_LAME_NOT_FOUND_HELP"
			fi
			exit $SMOOTH_RUN
		;;
		*)
			echo "$mpcdec_status"
			echo "$MSG_INVALID_OPTION" && exit $ERR_INVALID_OPTION
		;;
	esac
	shift
done

[[ $mpcdec_status == 1 ]] && { echo "$MSG_MPCDEC_NOT_FOUND"; exit $ERR_MPCDEC_NOT_FOUND; }
[[ $lame_status == 1 ]] && { echo "$MSG_LAME_NOT_FOUND"; exit $ERR_LAME_NOT_FOUND; }

[ $LOOP == 0 ] && test -z "$file" && echo "$MSG_USE_FILE_OPTION" && exit $ERR_OPTION_MISSING

create_mp3()
{
	echo "converting file '${1##*/}' (may take some time...)"
	mpcdec "$1" "${1%.*}".wav > /dev/null 2>&1
	if [ -f "${1%.*}".wav ]
	then
		lame $LAME_FLAGS "${1%.*}".wav "${1%.*}".mp3
		if [ -f "${1%.*}".mp3 ]
		then
			echo "file ${1%.*}.mp3 created!"
		else
			echo "problem in 'lame' converting "${1%.*}".wav to mp3 format" && exit $ERR_LAME_PROBLEM
		fi
		rm "${1%.*}".wav		
	else
		echo "problem in 'mpcdec' converting '${1##*/}' to wav format" && exit $ERR_MPCDEC_PROBLEM
	fi	
}

[ $LOOP == 0 ] && create_mp3 "$file" && exit $SMOOTH_RUN

for f in *
do
	[[ "${f##*.}" == "mpc" ]] && create_mp3 "$f"
#	[[ ${f##*.}=~"\.(mpc)" ]] && create_mp3 "$f"
#TODO regex aqui
done

#TODO
# - Handle mpcdec and lame return values
# - Maybe a option to keep the wav files
# - There are better ways to check if a program exists (instead of using 'command -v')
# - Maybe a extended '-a' option with recursion

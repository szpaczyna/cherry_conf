#!/bin/bash

# Possible color code are:

# Color     Foreground     Background
# black         30                     40
# red             31                     41
# green         32                     42
# yellow         33                     43
# blue             34                     44
# magenta     35                     45
# cyan             36                     46
# white         37                     47

# For more information have a look at http://tldp.org/LDP/abs/html/colorizing.html#AEN19813

# Set default background color
DFT_BG='\E[40m'
# Set default foreground color
DFT_FG='\E[32m'
# Set color for today marking
THIS_DAY_COLOR='\E[47m'

TODAY_DAY=`date | awk -F" " '{print $2}' | sed 's/\.//'`

days=`cal | sed 's/[a-zA-Z]//g' | sed 's/\S\S\S\S//g'`

case "$1" in
    vertical)
        echo -e ${DFT_BG}${DFT_FG}
        for day in ${days}
        do
            [ ${day} -eq ${TODAY_DAY} ] && echo -e "${THIS_DAY_COLOR}${day}${DFT_BG}${DFT_FG}"
            [ ! ${day} -eq ${TODAY_DAY} ] && echo -e ${day}
        done
    ;;
    horizontal)
        echo -e ${DFT_BG}${DFT_FG}
        for day in ${days}
        do
            [ ${day} -eq ${TODAY_DAY} ] && month="${month} ${THIS_DAY_COLOR}${day}${DFT_BG}${DFT_FG}"
            [ ! ${day} -eq ${TODAY_DAY} ] && month="${month} ${day}"
        done
        echo -e ${month}
    ;;
esac

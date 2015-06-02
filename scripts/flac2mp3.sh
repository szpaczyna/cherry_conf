#! /bin/sh

for a in *.flac; do
    OUTF=${a%.flac}.mp3

    ARTIST=`metaflac "$a" --show-tag=ARTIST | sed s/.*=//g`
    TITLE=`metaflac "$a" --show-tag=TITLE | sed s/.*=//g`
    ALBUM=`metaflac "$a" --show-tag=ALBUM | sed s/.*=//g`
    GENRE=`metaflac "$a" --show-tag=GENRE | sed s/.*=//g`
    TRACKNUMBER=`metaflac "$a" --show-tag=TRACKNUMBER | sed s/.*=//g`
    DATE=`metaflac "$a" --show-tag=DATE | sed s/.*=//g`

    flac -c -d "$a" | lame --noreplaygain -V0 -q 2 -b 320 \
        --add-id3v2 --pad-id3v2 --ignore-tag-errors --tt "$TITLE" --tn "${TRACKNUMBER:-0}" \
        --ta "$ARTIST" --tl "$ALBUM" --ty "$DATE" --tg "${GENRE:-12}" \
        - "$OUTF"
    RESULT=$?
    if [ "$1" ] && [ "$1" = "-d" ] && [ $RESULT -eq 0 ]; then
        rm "$a"
    fi
done


#for a in *.flac; do
#    OUTF=${a%.flac}.mp3
#
#    ARTIST=$(metaflac "$a" --show-tag=ARTIST | sed s/.*=//g)
#    TITLE=$(metaflac "$a" --show-tag=TITLE | sed s/.*=//g)
#    ALBUM=$(metaflac "$a" --show-tag=ALBUM | sed s/.*=//g)
#    GENRE=$(metaflac "$a" --show-tag=GENRE | sed s/.*=//g)
#    TRACKNUMBER=$(metaflac "$a" --show-tag=TRACKNUMBER | sed s/.*=//g)
#    DATE=$(metaflac "$a" --show-tag=DATE | sed s/.*=//g)

#    flac -c -d "$a" | lame -m j -q 0 --vbr-new -V 0 -s 44.1 - "$OUTF"
#    id3 -t "$TITLE" -T "${TRACKNUMBER:-0}" -a "$ARTIST" -A "$ALBUM" -y "$DATE" -g "${GENRE:-12}" "$OUTF"
#done

#!/bin/bash

BASE_DIR=$(dirname $0)

[[ -x $BASE_DIR/convert264 ]] || {
    echo "Can't find extraction progrm convert264"
    exit 2
}

SRC_FILE="$1"

function convert()
{
    local SRC_FILE="$1"
    
    [[ -f "$SRC_FILE" ]] || {
        echo "Can't file src file $SRC_FILE"
       return 3
    }

    SRC_BASE=${SRC_FILE%%.264}

    if [[ ! -f ${SRC_BASE}.h264 ]]
    then
        rm -f ${SRC_BASE}.h264 ${SRC_BASE}.video.ts.txt
        $BASE_DIR/convert264 "$SRC_FILE" || {
            echo "Failed to extract .h264 from .264"
            rm -f ${SRC_BASE}.h264 ${SRC_BASE}.video.ts.txt ${SRC_BASE}.wav ${SRC_BASE}.audio.ts.txt
            return 4
        }
        rm -f ${SRC_BASE}.wav ${SRC_BASE}.audio.ts.txt
    fi

    if [[ ! -f ${SRC_BASE}.mkv ]]
    then
        mkvmerge --output ${SRC_BASE}.mkv --timestamps "0:${SRC_BASE}.video.ts.txt" ${SRC_BASE}.h264 || {
            echo "Failed to create .mkv"
            return 5
        }
    fi

    if [[ ! -f ${SRC_BASE}.mp4 ]]
    then
        ffmpeg -framerate 10 -i ${SRC_BASE}.h264 -c copy ${SRC_BASE}.mp4 || {
            echo "Failed to create .mp4"
            return 6
        }
    fi
}

for SRC_FILE in $@
do
    convert "$SRC_FILE" || echo "Failed to convert $SRC_FILE: $?"
done

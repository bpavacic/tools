#!/bin/bash
# Creates a timelapse video from original video. Outputs every 16th frame and disables audio.
#
# Usage:
#   create-timelapse.sh <in_file> <out_file>

# Abort on any error.
set -e

if [ "$#" -ne 2 ]; then
    echo "Error: Wrong number of arguments"
    echo ""
    echo "Usage: $0 <input_file> <output_file>"
    exit 1
fi

INPUT=$1
OUTPUT=$2

# -movflags +faststart => speeds up video startup by storing bunch of metadata at the beginning of the file
# map_metadata 0 => Copies mp4 metadata (such as location of the video, time recorded etc) from the first input file
MPEG_OPTIONS="-movflags +faststart -map_metadata 0"

ffmpeg -i "$INPUT" -vf "setpts=PTS/16" -an $MPEG_OPTIONS "$OUTPUT"

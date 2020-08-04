#!/bin/bash
# Creates a timelapse video from original video. Outputs every 16th frame and disables audio.
#
# Usage:
#   create-timelapse.sh <in_file> <out_file>

# Abort on any error.
set -e

FACTOR=16

while test $# -gt 0
do
    case "$1" in
      -f)
          FACTOR=$2
          shift
          shift
          ;;
      *) 
          if [ -z "$INPUT" ];
          then
          	INPUT=$1
          else
     	     if [ -z "$OUTPUT" ];
     	     then
     	     	OUTPUT="$1"
     	     	args_ok=1
     		 else
     		 	args_ok=0
     		 fi
          fi
          shift
          ;;
    esac
done

if ! [[ "$args_ok" == "1" ]];
then
	echo ""
	echo "Error: invalid arguments"
	echo ""
	echo "Usage: $0 <file1> <file2> [options] "
	echo "Options:"
	echo "  -f speedup_factor (defaults to 16)"
	exit 1
fi

# -movflags +faststart => speeds up video startup by storing bunch of metadata at the beginning of the file
# map_metadata 0 => Copies mp4 metadata (such as location of the video, time recorded etc) from the first input file
MPEG_OPTIONS="-movflags +faststart -map_metadata 0"

ffmpeg -i "$INPUT" -vf "setpts=PTS/$FACTOR" -an $MPEG_OPTIONS "$OUTPUT"

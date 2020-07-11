#!/bin/bash
# Concatenates multiple video files into a single file.
#
# Usage:
#   concat-mp4-files.sh <file1> <file2> ... -o <output_file>"
#

# Abort on any error.
set -e

# -movflags +faststart => speeds up video startup by storing bunch of metadata at the beginning of the file
# map_metadata 0 => Copies mp4 metadata (such as location of the video, time recorded etc) from the first input file
MPEG_OPTIONS="-movflags +faststart -map_metadata 0 -ignore_unknown"

temp_file=`tempfile`
metadata_file=`tempfile`

function absolute_path {
    if [[ -d "$1" ]]
    then
        pushd "$1" >/dev/null
        pwd
        popd >/dev/null
    elif [[ -e $1 ]]
    then
        pushd "$(dirname "$1")" >/dev/null
        echo "$(pwd)/$(basename "$1")"
        popd >/dev/null
    else
        echo "$1" does not exist! >&2
        return 127
    fi
}

while test $# -gt 0
do
    case "$1" in
      -o)
          output_file=$2
          shift
          shift
          ;;
      *) 
          if [ -z "$have_inputs" ];
          then
            # Save metadata from the first input file.
            ffmpeg -i "`absolute_path $1`" -map_metadata 0 -f ffmetadata $metadata_file
            have_inputs=1
          fi
          echo "file '`absolute_path $1`'" >> $temp_file
          shift
          ;;
    esac
done

if [ -z "$have_inputs" ] ;then
  echo "Error: missing inputs"
  echo ""
  echo "Usage: $0 <file1> <file2> ... -o <output_file>"
  exit 1
fi

if [ -z "$output_file" ];
then
  echo "Error: missing output file"
  echo ""
  echo "Usage: $0 <file1> <file2> ... -o <output_file>"
  exit 2  
fi

ffmpeg -f concat -safe 0 -i $temp_file -i $metadata_file $MPEG_OPTIONS -map_metadata 1 -c copy "$output_file" \
  && rm $temp_file $metadata_file

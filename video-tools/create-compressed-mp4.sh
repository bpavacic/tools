#!/bin/sh
# Compresses a video to H.264 with bitrate that produces close to no visible loss of quality.

# Abort on any error.
set -e

if [ "$#" -ne 2 ]; then
    echo "Error: Illegal number of arguments"
    echo ""
    echo "Usage: $0 <input_file> <output_file>"
    exit 1
fi

INPUT=$1
OUTPUT=$2

# H.264 using X264 codec
# slower => increases quality by taking more time to process frames
# crf 26 => constant rate factor, determines target quality and bitrate. Lower means better quality,
#           larger size. Reasonable values are 17-28.
# -tune film => optimize algorithm for film (moving images, as opposed to animation/static
#               image/presentation etc)
VIDEO_OPTIONS="-c:v libx264 -preset slower -crf 26 -tune film"

# AAC audio codec, 128k target bitrate.
AUDIO_OPTIONS="-c:a aac -b:a 128k"
# -movflags +faststart => speeds up video startup by storing bunch of metadata at the beginning of
#                         the file.
# map_metadata 0 => Copies mp4 metadata (such as location of the video, time recorded etc) from the
#                   first input file
MPEG_OPTIONS="-movflags +faststart -map_metadata 0 -ignore_unknown"

ffmpeg -i "$INPUT" $AUDIO_OPTIONS $VIDEO_OPTIONS $MPEG_OPTIONS "$OUTPUT"
# Copy the filestamp.
touch -r "$INPUT" "$OUTPUT"


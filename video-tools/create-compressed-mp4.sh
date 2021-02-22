#!/bin/sh
# Compresses a video to H.264 with bitrate that produces close to no visible loss of quality.

# Abort on any error.
set -e

if [ "$#" -ne 2 ]; then
    echo "Error: Illegal number of arguments"
    echo ""
    echo "Usage: $0 <input_file> <output_file>"
    echo ""
    echo "If USE_VAAPI environment variable is set, GPU encoded will be used (experimental)"
    exit 1
fi

INPUT=$1
OUTPUT=$2

if [[ -z "${USE_VAAPI}" ]]; then
    # H.264 using X264 codec
    # slower => increases quality by taking more time to process frames
    # crf 26 => constant rate factor, determines target quality and bitrate. Lower means better quality,
    #           larger size. Reasonable values are 17-28.
    # -tune film => optimize algorithm for film (moving images, as opposed to animation/static
    #               image/presentation etc)
    VIDEO_OPTIONS="-c:v libx264 -preset slower -crf 26 -tune film"
else
    # H.264 using integrated GPU encoded (vaapi)
    # qp => The Quantization Parameter controls the amount of compression for every macroblock in a 
    #       frame. Large values mean that there will be higher quantization, more compression,
    #       and lower quality.
    VIDEO_OPTIONS="-vaapi_device /dev/dri/renderD128 -vf 'format=nv12,hwupload' -c:v h264_vaapi -qp 32"
fi

# AAC audio codec, 128k target bitrate.
AUDIO_OPTIONS="-c:a aac -b:a 128k"

# -movflags +faststart => speeds up video startup by storing bunch of metadata at the beginning of
#                         the file.
# map_metadata 0 => Copies mp4 metadata (such as location of the video, time recorded etc) from the
#                   first input file
MPEG_OPTIONS="-movflags +faststart -map_metadata 0 -ignore_unknown"

ffmpeg -i "$INPUT" $AUDIO_OPTIONS $VIDEO_OPTIONS $MPEG_OPTIONS "$OUTPUT"
# Copy the file timestamp.
touch -r "$INPUT" "$OUTPUT"


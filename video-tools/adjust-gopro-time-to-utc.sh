#!/bin/bash
#
# Adjusts GoPro .mp4 video timestamps to UTC time zone.
#
# GoPro cameras have no notion of time zones and have date/time metadata in recorded videos
# incorrectly set to local camera time, against MP4 specifications recommendation to have it set to
# UTC.
#
# This script adjusts the .mp4 timestamps to UTC time zone by substracting or adding the time zone 
# offset.
#
# Assumes both the GoPro and the computer have time set in your local time zone.
#
# Usage:
#
#   ./adjust-gopro-time-to-utc.sh <file name>

# Abort on any error.
set -e

# Check arguments.
if [ "$#" -ne 1 ]; then
    echo "Error: Invalid number of arguments"
    echo ""
    echo "Usage: $0 <file_name>"
    exit 1
fi

INPUT=$1

# Get the current timezone.
my_offset=`date +"%::z"`  # %::z   +hh:mm:ss numeric time zone (e.g., -04:00:00)

# Calculate the offset to add or substract.
if [[ "${my_offset:0:1}" == "+" ]];
then 
	apply="-=${my_offset:1}"
else
	apply="+=${my_offset:1}"
fi

# Adjust all date/time .mp4 tags to UTC.
exiftool -overwrite_original_in_place -api largefilesupport=1 \
    -*CreateDate$apply -*ModifyDate${apply} -DateTimeOriginal$apply  "$INPUT"

# Adjust the file's modification time. Now that the metadata tags are in UTC, run the command
# pretending that we are in UTC time zone.
TZ=UTC exiftool -overwrite_original_in_place -api largefilesupport=1 \
    "-CreateDate>FileModifyDate" "$INPUT"

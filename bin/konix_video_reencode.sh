#!/bin/bash -x

video="$1"
video_no_ext="${video%.*}"
HandBrakeCLI -2 -Z "Universal" -i "${video}" -o "${video_no_ext}.mkv"
rm -rf "${video}"

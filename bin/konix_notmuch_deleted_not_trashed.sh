#!/bin/bash

OUTPUT=summary
while getopts "hf" opt; do
    case $opt in
        h)
            usage
            exit 0
            ;;
        f)
            OUTPUT="files"
            ;;
    esac
done
shift $((OPTIND-1))

notmuch search --output=${OUTPUT} tag:deleted and not \( $(konix_notmuch_trash_folders_query.py) \)

#!/bin/bash
IFS=$'\n'
echo "SYNCING with $1" >&2

source _konix_sync_variables.sh
LIST_OF_SYNC_FILE="$(mktemp -t list_of_sync_file.XXXX)"
find ./ -name "$KONIX_SYNC_MAIN_DIR_FILE" > "$LIST_OF_SYNC_FILE"
LIST_OF_SYNC="$(< "$LIST_OF_SYNC_FILE")"
rm "$LIST_OF_SYNC_FILE"
for to_sync_dir_file in $LIST_OF_SYNC
do
    to_sync_dir="$(dirname $to_sync_dir_file)"
    OLD_DIR="$(pwd)"
    cd "$to_sync_dir"
    . _konix_sync_do.sh "$@"
    cd "${OLD_DIR}"
done

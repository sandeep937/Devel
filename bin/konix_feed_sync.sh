#!/bin/bash

# do a rss -> imap work
feed2imap -v -f "$KONIX_PERSO_DIR/feed2imaprc" | while read line
do
    if echo "$line" | grep -q 'FATAL\|ERROR'
    then
        echo "$line" >&2
    else
        echo "$line"
    fi
done
# clean the old rss
#feed2imap-cleaner -f "$KONIX_PERSO_DIR/feed2imaprc"

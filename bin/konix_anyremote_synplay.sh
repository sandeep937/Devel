#!/bin/bash -x

mkfifo "${HOME}/.mplayer/fifo" 2> /dev/null
anyremote -f "${KONIX_CONFIG_DIR}/anyremote/syncplay.cfg" -s tcp:5197,bluetooth:19,web:5080,avahi

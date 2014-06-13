#!/bin/bash

set -eux
DIR="${KONIX_PERSO_DIR}/${HOSTNAME}/aptitude_nd"
mkdir -p "${DIR}"
aptitude search '~i ?not(~M) ?not(?user-tag(.))' > "${DIR}/list"
cp "/var/lib/aptitude/pkgstates" "${DIR}/state"

#!/bin/bash

source "${KONIX_LIB_DIR}/lib_bash.sh"

set -eu
#set -x
LAST_OFX="$(ls *ofx* | tail -1)"
konix_assert_var LAST_OFX
ACCOUNT="$(konix_ofx_get_info.sh -a "${LAST_OFX}")"
DATE_STR="$(konix_ofx_get_info.sh -d "${LAST_OFX}")"
BANK="$(konix_ofx_get_info.sh -b "${LAST_OFX}")"
konix_assert_var ACCOUNT
konix_assert_var DATE_STR
konix_assert_var BANK
DATE="$(date '+%Y-%m-%d %H:%M:%S' -d@"${DATE_STR}")"
NOW_STR="$(date '+%s')"

boobank -q history "${ACCOUNT}@${BANK}" "${DATE}" -f ofx > "${ACCOUNT}_${BANK}_${NOW_STR}.ofx"
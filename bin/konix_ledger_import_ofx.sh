#!/bin/bash

set -eu
OFX_FILE_PATH="$(readlink -f "${1}")"
OFX_FILE_NAME="$(basename "${OFX_FILE_PATH}")"
FID=1
DATE="$(date)"
ACCOUNT="Assets:Bank:$(echo "${OFX_FILE_NAME}"|sed -r "s/^([^_]+)_([^_]+)_.+$/\2:\1/")"

# ledger does not like brackets
sed -i 's/[()]/_/g' "${OFX_FILE_PATH}"

# ledger-autosync does not explicitly encode output
export PYTHONIOENCODING=utf_8

CMD="ledger-autosync --assertions --fid 1 -a ${ACCOUNT}"
if ! ledger accounts|grep -q "${ACCOUNT}"
then
    CMD="${CMD} --initial"
fi
CMD="$CMD ${OFX_FILE_PATH}"
{
    echo ""
    echo "; ${DATE}"
    echo "; import command: $CMD"
    echo ""
    ${CMD}
    echo "; end of import"
} >> "${LEDGER_FILE}"

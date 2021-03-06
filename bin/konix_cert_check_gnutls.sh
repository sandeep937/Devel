#!/bin/bash

SERVER="$1"
PORT="${2:-443}"

GNU_TLS_OUT="$(mktemp -t gnutls_out.XXXX)"
trap "rm ${GNU_TLS_OUT}" 0

echo| gnutls-cli \
    --x509cafile "$KONIX_CA_FILE" \
    --print-cert \
    "$SERVER" -p "$PORT" > "${GNU_TLS_OUT}" 2>&1
RES="$?"
grep "${GNU_TLS_OUT}" \
    -e "Peer's certificate issuer is unknown" \
    -e "Peer's certificate is NOT trusted" \
    -e "Processed" \
    -e "Peer's certificate is trusted" \
    -e "The hostname in the certificate matches"

exit $RES

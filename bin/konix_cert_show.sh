#!/bin/bash

TIMEOUT="${3:-10}"

TESTS="konix_cert_show_openssl.sh konix_cert_show_gnutls.sh"

for t in $TESTS
do
    echo "attempting $t">&2
    eval timeout $TIMEOUT $t "$@"
    RES="$?"
    if [ "$RES" == "124" ]
    then
        echo "$t timed out" >&2
    else
        exit "$RES"
    fi
done

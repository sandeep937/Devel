#!/bin/bash

set -eu
mkdir -p "$KONIX_PERSO_DIR/gnupg"
echo "Saving the public keys"
gpg --export --armor \
    | gpg --encrypt --sign --recipient "$(konix_gpgdir_default_key.py)" > "${KONIX_PERSO_DIR}/gnupg_nd/pubring.gpg"
echo "Saving the ownertrust"
gpg --export-ownertrust --armor \
    | gpg --encrypt --sign --recipient "$(konix_gpgdir_default_key.py)" > "${KONIX_PERSO_DIR}/gnupg_nd/trustdb.txt.gpg"
echo "Done"

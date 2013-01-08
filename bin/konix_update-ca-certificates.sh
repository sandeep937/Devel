#!/bin/sh -e
#
# update-ca-certificates
#
# Copyright (c) 2003 Fumitoshi UKAI <ukai@debian.or.jp>
# Copyright (c) 2009 Philipp Kern <pkern@debian.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02111-1301,
# USA.
#

verbose=0
fresh=0
while [ $# -gt 0 ];
do
  case $1 in
  --verbose|-v)
  	verbose=1;;
  --fresh|-f)
	fresh=1;;
  --help|-h|*)
	echo "$0: [--verbose] [--fresh]"
	exit;;
  esac
  shift
done

CERTSCONF="$KONIX_PERSO_DIR/ca-certificates.conf"
CERTSDIR=/usr/share/ca-certificates
LOCALCERTSDIR="$KONIX_PERSO_DIR/ca-certificates"
CERTBUNDLE=ca-certificates.crt
ETCCERTSDIR="$KONIX_PERSO_DIR/ssl/certs"

cleanup() {
  rm -f "$TEMPBUNDLE"
  rm -f "$ADDED"
  rm -f "$REMOVED"
}
trap cleanup 0

# Helper files.  (Some of them are not simple arrays because we spawn
# subshells later on.)
TEMPBUNDLE="$(mktemp -t "${CERTBUNDLE}.tmp.XXXXXX")"
ADDED="$(mktemp -t "ca-certificates.tmp.XXXXXX")"
REMOVED="$(mktemp -t "ca-certificates.tmp.XXXXXX")"

# Adds a certificate to the list of trusted ones.  This includes a symlink
# in /etc/ssl/certs to the certificate file and its inclusion into the
# bundle.
add() {
  CERT="$1"
  PEM="$ETCCERTSDIR/$(basename "$CERT" .crt | sed -e 's/ /_/g' \
                                                  -e 's/[()]/=/g' \
                                                  -e 's/,/_/g').pem"
  if ! test -e "$PEM" || [ "$(readlink "$PEM")" != "$CERT" ]
  then
    ln -sf "$CERT" "$PEM"
    echo +$PEM >> "$ADDED"
  fi
  cat "$CERT" >> "$TEMPBUNDLE"
}

remove() {
  CERT="$1"
  PEM="$ETCCERTSDIR/$(basename "$CERT" .crt).pem"
  if test -L "$PEM"
  then
    rm -f "$PEM"
    echo -$PEM >> "$REMOVED"
  fi
}

cd $ETCCERTSDIR
if [ "$fresh" = 1 ]; then
  echo -n "Clearing symlinks in $ETCCERTSDIR..."
  find . -type l -print | while read symlink
  do
     case $(readlink $symlink) in
     $CERTSDIR*) rm -f $symlink;;
     esac
  done
  find . -type l -print | while read symlink
  do
     test -f $symlink || rm -f $symlink
  done
  echo "done."
fi

echo -n "Updating certificates in $ETCCERTSDIR... "

# Handle certificates that should be removed.  This is an explicit act
# by prefixing lines in the configuration files with exclamation marks (!).
sed -n -e '/^$/d' -e 's/^!//p' $CERTSCONF | while read crt
do
  remove "$CERTSDIR/$crt"
done

sed -e '/^$/d' -e '/^#/d' -e '/^!/d' $CERTSCONF | while read crt
do
  if ! test -f "$CERTSDIR/$crt"
  then
    echo "W: $CERTSDIR/$crt not found, but listed in $CERTSCONF." >&2
    continue
  fi
  add "$CERTSDIR/$crt"
done

# Now process certificate authorities installed by the local system
# administrator.
if [ -d "$LOCALCERTSDIR" ]
then
  find -L "$LOCALCERTSDIR" -type f -name '*.crt' | while read crt
  do
    add "$crt"
  done
fi

rm -f "$CERTBUNDLE"

ADDED_CNT=$(wc -l < "$ADDED")
REMOVED_CNT=$(wc -l < "$REMOVED")

if [ "$ADDED_CNT" -gt 0 ] || [ "$REMOVED_CNT" -gt 0 ]
then
  # only run if set of files has changed
  if [ "$verbose" = 0 ]
  then
    c_rehash . > /dev/null
  else
    c_rehash .
  fi
fi

chmod 0644 "$TEMPBUNDLE"
mv -f "$TEMPBUNDLE" "$CERTBUNDLE"

echo "$ADDED_CNT added, $REMOVED_CNT removed; done."

HOOKSDIR="$KONIX_PERSO_DIR/ca-certificates_hooks"
echo -n "Running hooks in $HOOKSDIR...."
VERBOSE_ARG=
[ "$verbose" = 0 ] || VERBOSE_ARG=--verbose
eval run-parts $VERBOSE_ARG --test -- $HOOKSDIR | while read hook
do
  ( cat $ADDED
    cat $REMOVED ) | $hook || echo E: $hook exited with code $?.
done
echo "done."

# vim:set et sw=2:

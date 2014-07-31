#!/bin/false
# Don't execute this file, source it!
# vim: set ts=4 sw=4 et sts=4 ai:

if [ -z "$SCRIPT_DIR" ]; then
    echo "$$SCRIPT_DIR not set!"
    exit 1
fi

TRAVIS_KEYFILE="$(readlink -f $SCRIPT_DIR/../.travis/id_rsa)"

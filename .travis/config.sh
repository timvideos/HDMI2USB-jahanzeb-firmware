#!/bin/echo Don't execute this file, source it!
# vim: set ts=4 sw=4 et sts=4 ai:
#
# Copyright (c) 2014, Tim 'mithro' Ansell
# All rights reserved.
#
# Avaliable under MIT license - http://opensource.org/licenses/MIT
# See ../LICENSE file for full text.

if [ -z "$SCRIPT_DIR" ]; then
    echo "$$SCRIPT_DIR not set!"
    exit 1
fi

TRAVIS_KEYFILE="$(readlink -f $SCRIPT_DIR/../.travis/id_rsa)"

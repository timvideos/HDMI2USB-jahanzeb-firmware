#!/bin/bash
# vim: set ts=4 sw=4 et sts=4 ai:
#
# Copyright (c) 2014, Tim 'mithro' Ansell
# All rights reserved.
#
# Avaliable under MIT license - http://opensource.org/licenses/MIT
# See ../LICENSE file for full text.

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $SCRIPT_DIR/config.sh

# Setup our SSH config environment
[ -d ~/.ssh ] || mkdir ~/.ssh

if [ -e ~/.ssh/known_hosts ]; then
    echo "Found ~/.ssh/known_hosts appending our own known hosts."
    cat .travis/ssh-known_hosts >> ~/.ssh/known_hosts
else
    echo "No ~/.ssh/known_hosts using our own."
    cp .travis/ssh-known_hosts ~/.ssh/known_hosts
fi
cat .travis/ssh-config >> ~/.ssh/config
echo "Final ~/.ssh/config contents"
echo "---------------------------------------------"
cat ~/.ssh/config
echo "---------------------------------------------"

# Start SSH agent
eval $(ssh-agent -s)

# Get the travis key -
# !!! - Need to set +x otherwise this will echo the private key into the logs!
if [ ! -e $TRAVIS_KEYFILE ]; then
    set +x
    if [ -z "$TRAVIS_SSHKEY_VALUE" ]; then
        echo "No SSH key found in environment, failing."
        exit 1
    fi
    # Decode SSH key from environment
    echo $SSH_KEY | base64 -d > $TRAVIS_KEYFILE
    chmod 0600 $TRAVIS_KEYFILE
else
    echo "Found existing SSH key with md5sum of $(md5sum .travis.key)"
fi

# Load the SSH key into SSH agent
ssh-add $TRAVIS_KEYFILE

# Echo out the key information
echo "Using SSH key of $TRAVIS_SSHKEY_NAME"
ssh-add -L

# Test the SSH connection to build.hdmi2usb.tv
ssh hdmi2usb@build.hdmi2usb.tv echo "SSH connection works!"

BRANCH_NAME="$TRAVIS_REPO_SLUG/$TRAVIS_BRANCH/number-$TRAVIS_JOB_ID-$TRAVIS_JOB_NUMBER/build-$TRAVIS_BUILD_ID-$TRAVIS_BUILD_NUMBER"
git branch $BRANCH_NAME
echo "Using branch name of '$BRANCH_NAME'"

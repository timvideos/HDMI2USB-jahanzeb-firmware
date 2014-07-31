#!/bin/bash
# vim: set ts=4 sw=4 et sts=4 ai:

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $SCRIPT_DIR/config.sh


set -e

if ! which travis > /dev/null; then
    echo "I need the travis tool installed to upload the SSH key."
    echo "Please follow the instructions at XXXXXX"
    exit 1
fi

if ! which ssh-keygen > /dev/null; then
    echo "I need the ssh-keygen tool to generate a SSH key."
    echo "Please install openssh-client."
    if [ -e /etc/lsb-release ]; then
        source /etc/lsb-release

        case $DISTRIB_ID in
            Ubuntu|Debian)
                echo "On Ubuntu and Debian systems run:"
                echo " sudo apt-get install openssh-client"
                ;;
        esac
    fi
    exit 1
fi

# Change to the script top level directory so travis commands work
cd $SCRIPT_DIR/..

# Get travis information for this repo
TRAVIS_USER="$(travis whoami --no-interactive)"
TRAVIS_REPO="$(travis settings --no-interactive | head -1)"

# Create the key if needed
if [ ! -e $TRAVIS_KEYFILE ];then
    export TRAVIS_SSHKEY_NAME="$TRAVIS_REPO@$(date +'%Y/%m/%d-%H:%M:%S')"
    ssh-keygen -b 2048 -t rsa -f $TRAVIS_KEYFILE -q -C "$TRAVIS_SSHKEY_NAME" -N ""
else
    export TRAVIS_SSHKEY_NAME="$(cat ${TRAVIS_KEYFILE}.pub | sed -e's/.* \([^ ]*\)/\1/')"
fi

# Upload key to travis
travis enable
travis env -P copy TRAVIS_SSHKEY_NAME
travis env -p set  TRAVIS_SSHKEY_VALUE "$(base64 -w0 $TRAVIS_KEYFILE)"

# Output pubkey part
echo
echo "Send the output below to mithro or shenki"
echo "========================================================================"
cat ${TRAVIS_KEYFILE}.pub

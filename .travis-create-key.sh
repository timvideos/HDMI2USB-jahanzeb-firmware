#! /bin/bash

set -e

travis whoami
REPO=$(travis settings --no-interactive | head -1)

# Create the key if needed
KEY_FILE=.travis.key
if [ ! -e $KEY_FILE ];then
    ssh-keygen -b 2048 -t rsa -f $KEY_FILE -q -N ""
fi

# Upload key to travis
travis enable
travis env set SSH_KEY "$(base64 -w0 $KEY_FILE)"

# Output pubkey part
echo
echo "Send the output below to mithro or shenki"
echo "========================================================================"
cat ${KEY_FILE}.pub | sed -e"s/ [^ ]\+\$/ travis@$REPO/"

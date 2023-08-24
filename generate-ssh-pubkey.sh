#!/bin/bash

_USERNAME=$1

if [[ `echo -n $_USERNAME | wc -c` == 0 ]]
then
  echo "Usage: $0 <NEW_USERNAME>"
  exit
fi

_IdentityFile="${_USERNAME}_id_rsa"

echo -e "### Generate id_rsa key ###\n"

ssh-keygen -t rsa -b 3072 -f $_IdentityFile

echo -e "\n### Ansible vars ###\n"

echo 'lines:'
echo "  - 'key-string'"
fold -b -w 72 ${_IdentityFile}.pub | xargs -I{} echo "  - '{}'"
echo "  - 'exit'"

echo -e "\n### IOS config ###\n"

echo 'ip ssh pubkey-chain'
echo " username $_USERNAME"
echo '  key-string'
fold -b -w 72 ${_IdentityFile}.pub
echo '  exit'
echo ' exit'
echo 'exit'

echo -e "\n### unset IOS config ###\n"
echo 'ip ssh pubkey-chain'
echo " no username $_USERNAME"
echo 'exit'
echo "no username $_USERNAME"
echo ""

echo -e "\n### id_rsa key's fingerprint ###\n"
ssh-keygen -E md5 -lf ${_IdentityFile}.pub
echo ""


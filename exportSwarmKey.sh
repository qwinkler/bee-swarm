#!/bin/bash
#
# This tool is used to export private key from Swarm Node

BASEDIR="/mnt/bee"
commitID="main"
exportedKeysPath="/root/bee-keys"

if [ $(id -u) != "0" ]; then
    echo "You have to run this scipt as a root user. Aborting."
    exit 1
fi

install() {
	if [ -f key.json ]; then
		rm key.json
	fi

	wget -qO exportSwarmKey https://raw.githubusercontent.com/qwinkler/bee-swarm/${commitID}/exportSwarmKey
	chmod +x exportSwarmKey

	echo "Enter the node password:"
	read  n
	echo 'Creating the private key'

	mkdir -p $exportedKeysPath
	cp ${BASEDIR}/data/keys/swarm.key ${exportedKeysPath}/swarm.key
	./exportSwarmKey ${exportedKeysPath} $n > key_tmp.json
	rm ${exportedKeysPath}/swarm.key
	sed 's/^[^{]*//' key_tmp.json > key.json
	rm key_tmp.json
  rmdir $exportedKeysPath
	echo "Your wallet: $(cat key.json | jq '.address')"
	echo "Your private key for export: $(cat key.json | jq '.privatekey')"
	echo "Private key file path: $(pwd)/key.json"
}

install
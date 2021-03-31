#!/bin/bash
#
# Script for Swarm Bee node installation

echo "Bee Swarm Node installation for Ubuntu/Debian"

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
LANG=ru_RU.UTF-8

BASEDIR="/mnt/bee"
if [ ! -d "$BASEDIR" ]; then
  echo "The ${BASEDIR} directory does not exist. Aborting"
  exit 1
fi

# base vars
dataDir="${BASEDIR}/data"
logPath="${BASEDIR}/run.log"
cashlogPath="${BASEDIR}/cash.log"
passPath="${BASEDIR}/bee-pass.txt"
swapEndpoint="https://rpc.slock.it/goerli"
cashScriptPath="${BASEDIR}/cashout.sh"
homedir="${BASEDIR}"
externalIp=$(curl -s -4 ifconfig.io)
commitID="main"
beeClientVersion="v0.5.3"
beeClefVersion="0.4.9"

if [ $(id -u) != "0" ]; then
    echo "You have to run this scipt as a root user. Aborting."
    exit 1
fi

mkdir -p $dataDir

# Installing the Swarm as a service
createSwarmService() {
  date "+【%Y-%m-%d %H:%M:%S】 Installing the Swarm Bee service" 2>&1 | tee -a $logPath
	if [ ! -f /etc/systemd/system/bee.service ]; then
	  cat >> /etc/systemd/system/bee.service << EOF
[Unit]
Description=Swarm Bee Node Service
After=network.target
StartLimitIntervalSec=0

[Service]
Type=simple
Restart=always
RestartSec=60
User=root
ExecStart=/usr/local/bin/bee start --config ${homedir}/bee-default.yaml

[Install]
WantedBy=multi-user.target
EOF
  echo 'Service already installed'
  else date "+【%Y-%m-%d %H:%M:%S】 Service already installed" 2>&1 | tee -a $logPath
  fi

  # Reload daemon
  systemctl daemon-reload

  # Enable bee service
  systemctl enable bee

  # Run the node itself
  systemctl start bee
}


# The function of installing a script for cashing checks
getCashoutScript() {
  if [ ! -f $cashScriptPath ]; then
  date "+【%Y-%m-%d %H:%M:%S】 The function of installing a script for cashing checks" 2>&1 | tee -a $logPath
  echo 'The function of installing a script for cashing checks';sleep 2

  # Download the scipt
  wget -O $cashScriptPath https://raw.githubusercontent.com/qwinkler/bee-swarm/$commitID/cashout.sh && chmod a+x $cashScriptPath
  else
  date "+【%Y-%m-%d %H:%M:%S】 '$cashScriptPath' File already exist" 2>&1 | tee -a $logPath
  fi

  # Write out current crontab
  crontab -l > mycron

  # Echo new cron into cron file
  echo "0 */12 * * *  /bin/bash $cashScriptPath cashout-all >> $cashlogPath 2>&1" >> mycron

  # Install new cron file
  crontab mycron
  rm -f mycron
  systemctl restart crond
}

createConfig() {
  date "+【%Y-%m-%d %H:%M:%S】 Create config" 2>&1 | tee -a $logPath
  echo 'Create config..'; sleep 2
  if [ ! -f $homedir/bee-default.yaml ]; then
    cat >> $homedir/bee-default.yaml << EOF
api-addr: :1633
bootnode:
- /dnsaddr/bootnode.ethswarm.org
clef-signer-enable: false
clef-signer-endpoint: ""
config: ${homedir}/bee-default.yaml
cors-allowed-origins: []
data-dir: ${dataDir}
db-capacity: "5000000"
debug-api-addr: :1635
debug-api-enable: true
gateway-mode: false
global-pinning-enable: false
help: false
nat-addr: "${externalIp}:1634"
network-id: "1"
p2p-addr: :1634
p2p-quic-enable: false
p2p-ws-enable: false
password: ""
password-file: ${passPath}
payment-early: "1000000000000"
payment-threshold: "10000000000000"
payment-tolerance: "50000000000000"
resolver-options: []
standalone: false
swap-enable: true
swap-endpoint: ${swapEndpoint}
swap-factory-address: ""
swap-initial-deposit: "100000000000000000"
tracing-enable: false
tracing-endpoint: 127.0.0.1:6831
tracing-service-name: bee
verbosity: 2
welcome-message: "Hello from qwinkler! https://github.com/qwinkler/bee-swarm"
EOF
  else date "+【%Y-%m-%d %H:%M:%S】 The config file already exists" 2>&1 | tee -a $logPath
  fi
}

function install() {
  if [ ! -f $passPath ]; then
  date "+【%Y-%m-%d %H:%M:%S】 Generating password file ${passPath}" 2>&1 | tee -a ${pwd}/run.log
  echo "Create the node password (will be stored here $passPath):"
  read  n
  echo  $n > $passPath;
  date "+【%Y-%m-%d %H:%M:%S】Your node password: " && cat $passPath  2>&1 | tee -a ${pwd}/run.log
  fi

  date "+【%Y-%m-%d %H:%M:%S】 Installing packages" 2>&1 | tee -a ${pwd}/run.log
  apt-get update
  apt -y install curl wget tmux jq

  echo 'Installing Swarm Bee client'; sleep 2
  date "+【%Y-%m-%d %H:%M:%S】 Installing Swarm Bee client" 2>&1 | tee -a ${pwd}/run.log
  curl -s https://raw.githubusercontent.com/ethersphere/bee/master/install.sh | TAG=$beeClientVersion bash

  echo 'Installing Bee Clef'; sleep 2

  date "+【%Y-%m-%d %H:%M:%S】 Installing Bee Clef" 2>&1 | tee -a ${pwd}/run.log
  wget -qO bee-clef.deb https://github.com/ethersphere/bee-clef/releases/download/v${beeClefVersion}/bee-clef_${beeClefVersion}_amd64.deb \
    && dpkg -i bee-clef.deb

  # wget -qO local-dash.sh https://github.com/doristeo/SwarmBeeBzzz/raw/main/local-dash.sh
  wget -qO local-dash.sh https://raw.githubusercontent.com/qwinkler/bee-swarm/$commitID/local-dash.sh
  chmod +x local-dash.sh

  createConfig
  getCashoutScript
  createSwarmService

  echo "Installation complete"
  echo "Your node password: $(cat $passPath). You can find it also here: $passPath"
  echo "Check the node status: systemctl status bee"
  echo "Check the logs: journalctl -f -u bee"
  sleep 10
  address="0x`cat ${dataDir}/keys/swarm.key | jq '.address' | sed 's/\"//g'`" && echo "Your node address: ${address}"
  echo "Add the test tokens to the node. Go to: https://discord.gg/f697tZaZjk, chat #faucet-request and create the message:"
  echo "sprinkle ${address}"
  echo "Instruction: https://telegra.ph/gbzz-geth-02-22"
}

install

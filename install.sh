#!/bin/bash
echo 'Установка пакетов'
sudo apt-get update
sudo apt -y install curl
sudo apt -y install wget
sudo apt -y install tmux
sudo apt -y install jq
echo 'Установка Swarm Bee'
curl -s https://raw.githubusercontent.com/ethersphere/bee/master/install.sh | TAG=v0.5.0 bash
echo 'Установка Bee Clef'
wget https://github.com/ethersphere/bee-clef/releases/download/v0.4.7/bee-clef_0.4.7_amd64.deb
sudo dpkg -i bee-clef_0.4.7_amd64.deb
echo 'Создание конфига'
echo "api-addr: :1633
bootnode:
- /dnsaddr/bootnode.ethswarm.org
clef-signer-enable: false
clef-signer-endpoint: ""
config: /root/.bee.yaml
cors-allowed-origins: []
data-dir: /root/.bee
db-capacity: "5000000"
debug-api-addr: :1635
debug-api-enable: true
gateway-mode: false
global-pinning-enable: false
help: false
nat-addr: ""
network-id: "1"
p2p-addr: :1634
p2p-quic-enable: false
p2p-ws-enable: false
password: ""
password-file: ""
payment-early: "1000000000000"
payment-threshold: "10000000000000"
payment-tolerance: "50000000000000"
resolver-options: []
standalone: false
swap-enable: true
swap-endpoint: https://goerli.prylabs.net
swap-factory-address: ""
swap-initial-deposit: "100000000000000000"
tracing-enable: false
tracing-endpoint: 127.0.0.1:6831
tracing-service-name: bee
verbosity: info
welcome-message: ""
" >> bee-config.yaml
echo 'Установка скрипта для обналичивания чеков'
wget https://github.com/grodstrike/bee-admin/raw/main/cashout.sh ~/cashout.sh
chmod 777 cashout.sh
#write out current crontab
crontab -l > mycron
#echo new cron into cron file
echo "0 */6 * * * /bin/bash ~/cashout.sh cashout-all » ~/cash.log   2>&1 " >> mycron
#install new cron file
crontab mycron
rm mycron
echo 'Запуск ноды'
tmux new -d -s bee
tmux send-keys -t bee.0 "bee start --config bee-config.yaml" ENTER
tmux a -t bee

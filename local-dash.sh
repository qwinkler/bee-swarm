#!/bin/bash

export COLOR_NC='\e[0m' # No Color
export COLOR_GREEN='\e[0;32m'
export COLOR_RED='\e[0;31m'
bold=$(tput bold)
normal=$(tput sgr0)
echo ""
echo -n "Bee version " ; bee version
echo ""
if pgrep -x "bee" > /dev/null
then
    na=$( curl -s localhost:1635/addresses | jq .ethereum | tr -d '"')
    cba=$(curl -s localhost:1635/chequebook/address | jq .chequebookaddress | tr -d '"')
    echo "Your address: ${bold}$na${normal}"
    echo "  Etherscan https://goerli.etherscan.io/address/$na"
    echo "Your chequebook: ${bold}$cba${normal}"
    echo "  Etherscan https://goerli.etherscan.io/address/$cba"
    echo ""
    echo -e "Bee node is ${COLOR_GREEN}running :)${COLOR_NC}"
    systemctl status bee | grep 'Active:'
    echo -n "Peers now: "; curl -s http://localhost:1635/peers | jq '.peers | length'
else
    echo -e "Bee node is ${COLOR_RED}NOT RUNNING! :(${COLOR_NC}"
    read -p "Do you want try to start node? (Yy/n)" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
      systemctl start bee
      echo "Please, wait 30sec and run this utility again..."
      echo "Good Beee!"
      echo "Bzzz..."
      exit 0
    fi
fi

echo ""
PS3='Please enter your choice:'
options=("Balance" "Manual cashout" "chequebook --gBzz--> node" "chequebook <--gBzz-- node" "Restart node" "Stop node" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Balance")
            echo "Balance of chequebook:"
            curl -s localhost:1635/chequebook/balance
            ;;
        "Manual cashout")
            echo "Manual cashout (./cashout.sh cashout-all >> /root/cash.log)..."
            ~/cashout.sh cashout-all >> /root/cash.log
            ;;
        "chequebook --gBzz--> node")
            echo "Move gBzz from cheque book to address of node..."
            thash=$(curl -XPOST -s localhost:1635/chequebook/withdraw\?amount\=1000 | jq .transactionHash | tr -d '"')
            echo "  Etherscan https://goerli.etherscan.io/tx/$thash"
            ;;
        "chequebook <--gBzz-- node")
            echo "Move gBzz from node's address to cheque book..."
            thash=$(curl -XPOST -s localhost:1635/chequebook/deposit\?amount\=1000 | jq .transactionHash |  tr -d '"')
            echo "  Etherscan https://goerli.etherscan.io/tx/$thash"
            ;;
        "Restart node")
            echo "Restarting node (systemctl restart bee)..."
            systemctl restart bee
            ;;
        "Stop node")
            echo "Stopping node (systemctl stop bee)..."
            systemctl stop bee
            ;;
        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
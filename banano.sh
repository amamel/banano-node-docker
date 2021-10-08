#!/bin/bash

# VERSION
version='0.1'

# FAST-SYNC DOWNLOAD LINK
ledgerDownloadLink='https://banano.steampoweredtaco.com/download/snapshot.ldb.gz'

# OUTPUT VARS
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
bold=`tput bold`
reset=`tput sgr0`

# FLAGS & ARGUMENTS
quiet='false'
displaySeed='false'
fastSync='false'
domain=''
email=''
tag=''
while getopts 'sqfd:e:t:' flag; do
  case "${flag}" in
    s) displaySeed='true' ;;
    d) domain="${OPTARG}" ;;
    e) email="${OPTARG}" ;;
    q) quiet='true' ;;
    f) fastSync='true' ;;
    t) tag="${OPTARG}" ;;
    *) exit 1 ;;
  esac
done

echo $@ > settings

# PRINT INSTALLER DETAILS
[[ $quiet = 'false' ]] && echo "${green} -----------------------${reset}"
[[ $quiet = 'false' ]] && echo "${green}${bold} Banano Node Docker ${version}${reset}"
[[ $quiet = 'false' ]] && echo "${green} -----------------------${reset}"
[[ $quiet = 'false' ]] && echo ""

# VERIFY TOOLS INSTALLATIONS
docker -v &> /dev/null
if [ $? -ne 0 ]; then
    echo "${red}Docker is not installed. Please follow the install instructions for your system at https://docs.docker.com/install/.${reset}";
    exit 2
fi

docker-compose --version &> /dev/null
if [ $? -ne 0 ]; then
    echo "${red}Docker Compose is not installed. Please follow the install instructions for your system at https://docs.docker.com/compose/install/.${reset}"
    exit 2
fi

if [[ $tag == '' ]]; then
    echo "${yellow}Banano node image tag is now required. Please set the -t argument explicitly to the version you are willing to install (https://hub.docker.com/r/bananocoin/banano/tags).${reset}"
    exit 2
fi

if [[ $fastSync = 'true' ]]; then
    wget --version &> /dev/null
    if [ $? -ne 0 ]; then
        echo "${red}wget is not installed and is required for fast-syncing.${reset}";
        exit 2
    fi

    7z &> /dev/null
    if [ $? -ne 0 ]; then
        echo "${red}7-Zip is not installed and is required for fast-syncing.${reset}";
        exit 2
    fi
fi

# FAST-SYNCING
if [[ $fastSync = 'true' ]]; then

    if [[ $quiet = 'false' ]]; then
        printf "=> ${yellow}Downloading latest ledger files for fast-syncing...${reset}\n"
        wget -O snapshot.ldb.gz ${ledgerDownloadLink} -q --show-progress

        printf "=> ${yellow}Unzipping and placing the files (takes a while)...${reset} "
        7z x snapshot.ldb.gz  -o./banano-node/Banano -y &> /dev/null
        rm snapshot.ldb.gz
        printf "${green}done.${reset}\n"
        echo ""

    else
        wget -O snapshot.ldb.gz ${ledgerDownloadLink} -q
        docker-compose stop banano-node &> /dev/null
        7z x snapshot.ldb.gz  -o./banano-node/Banano -y &> /dev/null
        rm snapshot.ldb.gz
    fi

fi

# DETERMINE IF THIS IS AN INITIAL INSTALL
[[ $quiet = 'false' ]] && echo "=> ${yellow}Checking initial status...${reset}"
[[ $quiet = 'false' ]] && echo ""

# check if node mounted directory exists
if [ -d "./banano-node" ]; then
    # check if mounted directory follows the new /root structure
    if [ ! -d "./banano-node/Banano" ]; then
        if [ ! -d "./banano-node/Banano" ]; then
            [[ $quiet = 'false' ]] && printf "${reset}Unsupported directory structure detected. Migrating files... "
            mkdir ./banano-node/Banano
            # move everything into subdirectory and suppress the error about itself
            mv ./banano-node/* ./banano-node/Banano/ &> /dev/null
            [[ $quiet = 'false' ]] && printf "${green}done.\n${reset}"
            [[ $quiet = 'false' ]] && echo ""
        fi
    fi
fi

# SPIN UP THE APPROPRIATE STACK
[[ $quiet = 'false' ]] && echo "=> ${yellow}Pulling images and spinning up containers...${reset}"
[[ $quiet = 'false' ]] && echo ""

docker network create banano-node-network &> /dev/null

if [[ $domain ]]; then

    if [[ $tag ]]; then
        sed -i -e "s/    image: bananocoin\/banano:.*/    image: bananocoin\/banano:$tag/g" docker-compose.letsencrypt.yml
    fi

    sed -i -e "s/      - VIRTUAL_HOST=.*/      - VIRTUAL_HOST=$domain/g" docker-compose.letsencrypt.yml
    sed -i -e "s/      - LETSENCRYPT_HOST=.*/      - LETSENCRYPT_HOST=$domain/g" docker-compose.letsencrypt.yml
    sed -i -e "s/      - DEFAULT_HOST=.*/      - DEFAULT_HOST=$domain/g" docker-compose.letsencrypt.yml

    if [[ $email ]]; then
        sed -i -e "s/      - LETSENCRYPT_EMAIL=.*/      - LETSENCRYPT_EMAIL=$email/g" docker-compose.letsencrypt.yml
    fi

    if [[ $quiet = 'false' ]]; then
        docker-compose -f docker-compose.letsencrypt.yml up -d
    else
        docker-compose -f docker-compose.letsencrypt.yml up -d &> /dev/null
    fi

else

    if [[ $tag ]]; then
        sed -i -e "s/    image: bananocoin\/banano:.*/    image: bananocoin\/banano:$tag/g" docker-compose.yml
    fi

    if [[ $quiet = 'false' ]]; then
        docker-compose up -d
    else
        docker-compose up -d &> /dev/null
    fi

fi

if [ $? -ne 0 ]; then
    echo "${red}Errors were encountered while spinning up the containers. Scroll up for more info on how to fix them.${reset}"
    exit 2
fi

# CHECK NODE INITIALIZATION
[[ $quiet = 'false' ]] && echo ""
[[ $quiet = 'false' ]] && printf "=> ${yellow}Waiting for Banano node to fully initialize... "

isRpcLive="$(curl -s -d '{"action": "version"}' [::1]:7072 | grep "rpc_version")"
while [ ! -n "$isRpcLive" ];
do
    sleep 1s
    isRpcLive="$(curl -s -d '{"action": "version"}' [::1]:7072 | grep "rpc_version")"
done

[[ $quiet = 'false' ]] && printf "${green}done.${reset}\n\n"

# DETERMINE NODE VERSION
nodeExec="docker exec -it banano-node /usr/bin/banano-node"

# SET BASH ALIASES FOR NODE CLI
if [ -f ~/.bash_aliases ]; then
    alias=$(cat ~/.bash_aliases | grep 'banano-node');
    if [[ ! $alias ]]; then
        echo "alias banano-node='${nodeExec}'" >> ~/.bash_aliases;
        source ~/.bashrc;
    fi
else
    echo "alias banano-node='${nodeExec}'" >> ~/.bash_aliases;
    source ~/.bashrc;
fi

# WALLET SETUP
existedWallet="$(${nodeExec} --wallet_list | grep 'Wallet ID' | awk '{ print $NF}')"

if [[ ! $existedWallet ]]; then
    [[ $quiet = 'false' ]] && printf "=> ${yellow}No wallet found. Generating a new one... ${reset}"

    walletId=$(${nodeExec} --wallet_create | tr -d '\r')
    address="$(${nodeExec} --account_create --wallet=$walletId | awk '{ print $NF}')"
    
    [[ $quiet = 'false' ]] && printf "${green}done.${reset}\n\n"
else
    [[ $quiet = 'false' ]] && echo "=> ${yellow}Existing wallet found.${reset}"
    [[ $quiet = 'false' ]] && echo ''

    address="$(${nodeExec} --wallet_list | grep 'ban_' | awk '{ print $NF}' | tr -d '\r')"
    walletId=$(echo $existedWallet | tr -d '\r')
fi

if [[ $quiet = 'false' && $displaySeed = 'true' ]]; then
    seed=$(${nodeExec} --wallet_decrypt_unsafe --wallet=$walletId | grep 'Seed' | awk '{ print $NF}' | tr -d '\r')
fi

# UPDATE MONITOR CONFIGS
if [ ! -f ./banano-node-monitor/config.php ]; then
    [[ $quiet = 'false' ]] && echo "=> ${yellow}No existing BANANO Node Monitor config file found. Fetching a fresh copy...${reset}"
    if [[ $quiet = 'false' ]]; then
        docker-compose restart banano-node-monitor
    else
        docker-compose restart banano-node-monitor > /dev/null
    fi
fi

[[ $quiet = 'false' ]] && printf "=> ${yellow}Configuring BANANO Node Monitor... ${reset}"

sed -i -e "s/\/\/ \$bananoNodeRPCIP.*;/\$bananoNodeRPCIP/g" ./banano-node-monitor/config.php
sed -i -e "s/\$bananoNodeRPCIP.*/\$bananoNodeRPCIP = 'banano-node';/g" ./banano-node-monitor/config.php

sed -i -e "s/\/\/ \$bananoNodeAccount.*;/\$bananoNodeAccount/g" ./banano-node-monitor/config.php
sed -i -e "s/\$bananoNodeAccount.*/\$bananoNodeAccount = '$address';/g" ./banano-node-monitor/config.php

if [[ $domain ]]; then
    sed -i -e "s/\/\/ \$bananoNodeName.*;/\$bananoNodeName = '$domain';/g" ./banano-node-monitor/config.php
else 
    ipAddress=$(curl -s v4.ifconfig.co | awk '{ print $NF}' | tr -d '\r')

    # in case of an ipv6 address, add square brackets
    if [[ $ipAddress =~ .*:.* ]]; then
        ipAddress="[$ipAddress]"
    fi

    sed -i -e "s/\/\/ \$bananoNodeName.*;/\$bananoNodeName = 'banano-node-docker-$ipAddress';/g" ./banano-node-monitor/config.php
fi

sed -i -e "s/\/\/ \$welcomeMsg.*;/\$welcomeMsg = 'Welcome! This node was setup using <a href=\"https:\/\/github.com\/amamel\/banano-node-docker\" target=\"_blank\">Banano Node Docker<\/a>!';/g" ./banano-node-monitor/config.php
sed -i -e "s/\/\/ \$blockExplorer.*;/\$blockExplorer = 'meltingice';/g" ./banano-node-monitor/config.php

# remove any carriage returns may have been included by sed replacements
sed -i -e 's/\r//g' ./banano-node-monitor/config.php

[[ $quiet = 'false' ]] && printf "${green}done.${reset}\n\n"

if [[ $quiet = 'false' ]]; then
    echo "${yellow} |=========================================================================================| ${reset}"
    echo "${yellow} | ${green}${bold}Congratulations! Banano Node Docker has been setup successfully!                          ${yellow}| ${reset}"
    echo "${yellow} |=========================================================================================| ${reset}"
    echo "${yellow} | Node account address: ${green}$address${yellow} | ${reset}"
    if [[ $displaySeed = 'true' ]]; then
        echo "${yellow} | Node wallet seed: ${red}$seed${yellow}      | ${reset}"
    fi
    echo "${yellow} |=========================================================================================| ${reset}"

    echo ""

    if [[ $domain ]]; then
        echo "${yellow} Open a browser and navigate to ${green}https://$domain${yellow} to check your monitor."
    else
        echo "${yellow} Open a browser and navigate to ${green}http://$ipAddress${yellow} to check your monitor."
    fi
    echo "${yellow} You can further configure and personalize your monitor by editing the config file located in ${green}banano-node-monitor/config.php${yellow}.${reset}"

    echo ""

fi

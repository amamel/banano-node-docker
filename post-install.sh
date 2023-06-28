#!/bin/bash

yellow='\033[0;33m'
green='\033[0;32m'
reset='\033[0m'


echo "${yellow}
##################################################
#  Banano Node Docker Post Installer After Party #
#  https://github.com/amamel/banano-node-docker  #
##################################################
${reset}"

# Function to check the operating system
check_os() {
  local os=$(uname -s)
  if [[ "$os" != "Linux" ]]; then
    echo "Sorry, '$os' operating system is not yet supported by this script. If you would like to see '$os' operating system supported, please add an issue on Github."
    exit 1
  fi
}

# ============================
# Post Node Setup Config
# ============================

echo "This script will ask you a series of questions to configure your Banano node setup:"
echo "Please answer each question with 'true' or 'false'."

# Enable RPC (Default 'true' for node setup to enable control)
read -p "Enable RPC Commands for Initial Node Configuration? [true/false]: " enable_rpc
if [[ $enable_rpc == "true" ]]; then
    sed -i 's/enable_control = false/enable_control = true/g' ./banano-node/BananoData/config-rpc.toml
    sed -i '/^\[rpc\]/{n;s/enable = false/enable = true/}' ./banano-node/BananoData/config-node.toml
    echo "=> ${green}RPC Commands enabled.${reset}"
else
    echo "=> ${yellow}RPC Commands disabled.${reset}"
fi

# Run as PR? (Enable Voting)
read -p "Enable Voting (Run as PR)? [true/false]: " enable_voting
if [[ $enable_voting == "true" ]]; then
    sed -i '/^\[node\]$/!b;a\node\enable_voting = true' ./banano-node/BananoData/config-node.toml
    echo "=> ${green}Voting enabled.${reset}"
else
    echo "=> ${yellow}Voting disabled.${reset}"
fi

# Using Rocks DB? (Tell Node to Use Rocks)
read -p "Use Rocks DB? [true/false]: " use_rocksdb
if [[ $use_rocksdb == "true" ]]; then
    sed -i '/^\[node\]$/a [node.rocksdb]\nenable = true' ./banano-node/BananoData/config-node.toml
    echo "=> ${green}Rocks DB enabled.${reset}"
else
    echo "=> ${yellow}Rocks DB disabled.${reset}"
fi

# Restart Docker Compose service
echo "=> Restarting Docker Compose service..."
docker-compose restart
echo "=> ${green}Done. Docker Compose service restarted.${reset}"


end() {
    echo -e "\n${green}${bold}Banano Node Docker finished successfully. Press any key to close.${reset}"
    read -n 1 -s -r -p ""  # Wait for user input of any key
}

# ================================================================================
# Check if the script finished successfully and call the function
# ================================================================================
if [ $? -eq 0 ]; then
    echo -e "\n\n\n\n"
    end  # Call the function to display message and wait for keypress
fi

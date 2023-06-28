#!/bin/bash

red='\033[0;31m'
yellow='\033[0;33m'
green='\033[0;32m'
reset='\033[0m'

echo -e "${yellow}
##################################################
#  Banano Node Docker Post Installer After Party #
#  https://github.com/amamel/banano-node-docker  #
##################################################
${reset}"

# Function to check the operating system
check_os() {
  local os=$(uname -s)
  if [[ "$os" != "Linux" ]]; then
    echo -e "=> ${red}Sorry, '$os' operating system is not yet supported by this script. If you would like to see '$os' operating system supported, please add an issue on Github.${reset}"
    exit 1
  fi
}

# Configure ufw ports for Banano Nano Node
read -p "${yellow}Configure ufw ports for Banano Nano Node? [yes/no]${reset}: " configure_ufw
if [[ $configure_ufw == "yes" ]]; then
  sudo ufw allow http
  sudo ufw allow 7071
  sudo ufw allow 7072
  sudo ufw allow 7074
  echo -e "=> ${green}ufw ports configured.${reset}"
else
  echo -e "=> ${yellow}Skipping ufw configuration.${reset}"
fi

# Enable RPC (Default 'true' for node setup to enable control)
read -p "${yellow}Enable RPC Commands for Initial Node Configuration? [true/false]:${reset} " enable_rpc
if [[ $enable_rpc == "true" ]]; then
  sed -i 's/enable_control = false/enable_control = true/g' ./banano-node/BananoData/config-rpc.toml
  sed -i '/^\[rpc\]/{n;s/enable = false/enable = true/}' ./banano-node/BananoData/config-node.toml
  echo -e "=> ${green}RPC Commands enabled.${reset}"
else
  echo -e "=> ${yellow}RPC Commands disabled.${reset}"
fi

# Run as PR? (Enable Voting)
read -p "${yellow}Enable Voting (Run as PR)? [true/false]:${reset} " enable_voting
if [[ $enable_voting == "true" ]]; then
  sed -i '/^\[node\]$/!b;a\node\enable_voting = true' ./banano-node/BananoData/config-node.toml
  echo -e "=> ${green}Voting enabled.${reset}"
else
  echo -e "=> ${yellow}Voting disabled.${reset}"
fi

# Using Rocks DB? (Tell Node to Use Rocks)
read -p "${yellow}Use Rocks DB? [true/false]:${reset} " use_rocksdb
if [[ $use_rocksdb == "true" ]]; then
  sed -i '/^\[node\]$/a [node.rocksdb]\nenable = true' ./banano-node/BananoData/config-node.toml
  echo -e "=> ${green}Rocks DB enabled.${reset}"
else
  echo -e "=> ${yellow}Rocks DB disabled.${reset}"
fi

# Restart Docker Compose service
echo -e "=> ${yellow}Restarting Docker Compose service...${reset}"
docker-compose restart
echo -e "=> ${green}Done. Docker Compose service restarted.${reset}"

# Function to display the end message and wait for keypress
end() {
  echo -e "\n${green}Banano Node Docker Post Install finished successfully. Press any key to close.${reset}"
  read -n 1 -s -r -p ""  # Wait for user input of any key
}

# Check if the script finished successfully and call the function
if [ $? -eq 0 ]; then
  echo -e "\n\n\n\n"
  end  # Call the function to display the message and wait for keypress
fi

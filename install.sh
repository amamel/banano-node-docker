#!/bin/bash

yellow='\033[0;33m'
green='\033[0;32m'
reset='\033[0m'

echo -e "${yellow}================================${reset}"
echo -e "${yellow}Banano Node Docker Installation ${reset}"
echo -e "${yellow}================================${reset}"

# Clone or update the Banano Node Docker repository
echo -e "=> ${yellow}Cloning installation${reset}"
git -C /opt/banano-node-docker pull || git clone https://github.com/amamel/banano-node-docker.git /opt/banano-node-docker

# User prompt for installation option

declare -A options=(
  ["Banano Node with Node Monitor"]="-t latest -s"
  ["Banano Node with SSL"]="-d domain -e email -s -t latest"
  ["Banano Node with Fast Sync DB (Experimental)"]="-f -t latest"
  ["Banano Node with SSL and Fast Sync (Experimental)"]="-d domain -e email -s -f -t latest"
  ["Quit"]="quit"
)

PS3="${yellow}Enter your choice: ${reset}"
selected_option=""
options_list=()

for opt in "${!options[@]}"; do
  options_list+=("$opt")
done

select opt in "${options_list[@]}"; do
  case $opt in
    "Banano Node with Node Monitor")
      selected_option=${options[$opt]}
      break
      ;;
    "Banano Node with SSL")
      selected_option=${options[$opt]}
      break
      ;;
    "Banano Node with Fast Sync DB (Experimental)")
      selected_option=${options[$opt]}
      break
      ;;
    "Banano Node with SSL and Fast Sync (Experimental)")
      selected_option=${options[$opt]}
      break
      ;;
    "Quit")
      selected_option=${options[$opt]}
      break
      ;;
  esac
done

case $selected_option in
  "quit")
    echo -e "${yellow}Quitting...${reset}"
    exit
    ;;
  *)
    echo -e "=> ${green}Starting installation...${reset}"
    if [[ $selected_option == *"SSL"* ]]; then
      read -p "Enter your domain: " domain
      read -p "Enter your email: " email
    fi
    sudo bash /opt/banano-node-docker/banano.sh ${selected_option[@]} "$domain" "$email"
    ;;
esac

#!/bin/bash

echo "================================"
echo "Banano Node Docker Installation"
echo "================================"

# Clone or update the Banano Node Docker repository
echo "== Cloning installation"
git -C /opt/banano-node-docker pull || git clone https://github.com/amamel/banano-node-docker.git /opt/banano-node-docker

# User prompt for installation option

declare -A options=(
  ["Banano Node with Node Monitor"]="-t latest"
  ["Banano Node with SSL"]="-d domain -e email -s"
  ["Banano Node with Fast Sync DB (Experimental)"]="-f"
  ["Banano Node with SSL and Fast Sync (Experimental)"]="-d domain -e email -s -f"
  ["Quit"]="quit"
)

PS3="Enter your choice: "
selected_option=""

select opt in "${!options[@]}"; do
  case $opt in
    *)
      selected_option=${options[$opt]}
      break
      ;;
  esac
done

case $selected_option in
  "quit")
    echo "Quitting..."
    exit
    ;;
  *)
    echo "== Starting installation"
    if [[ $selected_option == *"SSL"* ]]; then
      read -p "Enter your domain: " domain
      read -p "Enter your email: " email
    fi
    sudo bash /opt/banano-node-docker/banano.sh ${selected_option[@]} "$domain" "$email"
    ;;
esac

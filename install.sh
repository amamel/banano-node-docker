#!/bin/bash

# Enable error handling
set -e

# Display installation header
echo "================================"
echo "Banano Node Docker"
echo "================================"

# Clone or update the Banano Node Docker repository
echo "[i] Cloning installation"
git -C /opt/banano-node-docker pull || git clone https://github.com/amamel/banano-node-docker.git /opt/banano-node-docker

# User prompt for installation option

# Declare associative array for installation options
declare -A options=(
  ["Banano Node with Node Monitor"]="-t latest -s"
  ["Banano Node Fast Sync"]="-f -t latest"
  ["Banano Node with SSL"]="-d domain -e email -s -t latest"
  ["Banano Node with SSL, & Fast Sync"]="-d domain -e email -s -f -t latest"
  ["Quit"]="quit"
)

# Prompt message for selecting an option
PS3="Enter your installation choice: "

selected_option=""
options_list=()

# Prepare list of options for selection
for opt in "${!options[@]}"; do
  options_list+=("$opt")
done

IFS=$'\n' # Set the internal field separator to newline

# Display menu and read user's selection
select opt in "${options_list[@]}"; do
  case $opt in
  "Banano Node with Node Monitor")
    selected_option=${options[$opt]}
    break
    ;;
  "Banano Node Fast Sync")
    selected_option=${options[$opt]}
    break
    ;;
  "Banano Node with SSL")
    selected_option=${options[$opt]}
    read -p "Enter your domain: " domain
    read -p "Enter your email: " email
    break
    ;;
  "Banano Node with SSL, & Fast Sync")
    selected_option=${options[$opt]}
    read -p "Enter your domain: " domain
    read -p "Enter your email: " email
    break
    ;;
  "Quit")
    selected_option=${options[$opt]}
    break
    ;;
  esac
done

# Process selected option
case $selected_option in
"quit")
  echo "[i] Quitting..."
  exit
  ;;
*)
  echo "[i] Starting installation..."
  if [[ $selected_option == *"SSL"* ]]; then
    sudo bash /opt/banano-node-docker/banano.sh ${options[$opt]} -d "$domain" -e "$email"
  else
    sudo bash /opt/banano-node-docker/banano.sh ${options[$opt]}
  fi
  ;;
esac

# Error handling
if [ $? -ne 0 ]; then
  exit_code=$?
  echo "[ERROR] An unexpected error occurred. Exit code: $exit_code"
  exit $exit_code
fi

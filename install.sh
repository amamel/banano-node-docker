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

# Display menu and read user's selection
while true; do
  for ((i = 1; i <= ${#options_list[@]}; i++)); do
    echo "$i) ${options_list[$i - 1]}"
  done
  read -p "Enter your installation choice: " choice
  if [[ "$choice" =~ ^[0-9]+$ ]] && ((choice >= 1 && choice <= ${#options_list[@]})); then
    selected_option=${options[${options_list[$choice - 1]}]}
    break
  else
    echo "Invalid choice. Please try again."
  fi
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
    sudo bash /opt/banano-node-docker/banano.sh ${selected_option[@]} -d "$domain" -e "$email"
  else
    sudo bash /opt/banano-node-docker/banano.sh ${selected_option[@]}
  fi
  ;;
esac

# Error handling
if [ $? -ne 0 ]; then
  exit_code=$?
  echo "[ERROR] An unexpected error occurred. Exit code: $exit_code"
  exit $exit_code
fi

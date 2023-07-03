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

# Declare associative array for installation options
declare -A options=(
  ["1"]="Banano Node with Node Monitor"
  ["2"]="Banano Node Fast Sync"
  ["3"]="Banano Node with SSL"
  ["4"]="Banano Node with SSL, & Fast Sync"
  ["5"]="Quit"
)

selected_option=""
valid_options=("1" "2" "3" "4" "5")

# Display menu and read user's selection
while [[ -z $selected_option ]]; do
  echo "Please select an installation option:"
  for option in "${!options[@]}"; do
    echo "$option) ${options[$option]}"
  done

  read -p "Enter your installation choice: " choice

  if [[ " ${valid_options[@]} " =~ " $choice " ]]; then
    selected_option=${options["$choice"]}
    break
  else
    echo "Invalid choice. Please try again."
  fi
done

# Process selected option
case $selected_option in
"Quit")
  echo "[i] Quitting..."
  exit
  ;;
*)
  echo "[i] Starting installation..."
  if [[ $selected_option == "Banano Node with SSL" || $selected_option == "Banano Node with SSL, & Fast Sync" ]]; then
    read -p "Enter your domain: " domain
    read -p "Enter your email: " email
    sudo bash /opt/banano-node-docker/banano.sh ${selected_option,,} -d "$domain" -e "$email"
  else
    sudo bash /opt/banano-node-docker/banano.sh ${selected_option,,}
  fi
  ;;
esac

# Error handling
if [ $? -ne 0 ]; then
  exit_code=$?
  echo "[ERROR] An unexpected error occurred. Exit code: $exit_code"
  exit $exit_code
fi

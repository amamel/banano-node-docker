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
  ["Banano Node with Node Monitor"]="-t latest -s"
  ["Banano Node Fast Sync"]="-f -t latest"
  ["Banano Node with SSL"]="-d domain -e email -s -t latest"
  ["Banano Node with SSL, & Fast Sync"]="-d domain -e email -s -f -t latest"
  ["Quit"]="quit"
)

selected_option=""
valid_options=("1" "2" "3" "4" "5")

# Display menu and read user's selection
while [[ -z $selected_option ]]; do
  echo "Please select an installation option:"
  echo "1) Banano Node with Node Monitor"
  echo "2) Banano Node Fast Sync"
  echo "3) Banano Node with SSL"
  echo "4) Banano Node with SSL, & Fast Sync"
  echo "5) Quit"

  read -p "Enter your installation choice: " choice

  if [[ " ${valid_options[@]} " =~ " $choice " ]]; then
    case $choice in
    1)
      selected_option=${options["Banano Node with Node Monitor"]}
      break
      ;;
    2)
      selected_option=${options["Banano Node Fast Sync"]}
      break
      ;;
    3)
      selected_option=${options["Banano Node with SSL"]}
      read -p "Enter your domain: " domain
      read -p "Enter your email: " email
      break
      ;;
    4)
      selected_option=${options["Banano Node with SSL, & Fast Sync"]}
      read -p "Enter your domain: " domain
      read -p "Enter your email: " email
      break
      ;;
    5)
      selected_option=${options["Quit"]}
      break
      ;;
    *)
      echo "Invalid choice. Please try again."
      ;;
    esac
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

#!/bin/bash

# Clone or update the Banano Node Docker repository
echo "== Cloning installation"
git -C /opt/banano-node-docker pull || git clone https://github.com/amamel/banano-node-docker.git /opt/banano-node-docker

# User prompt for installation option
echo "== Select an installation option:"
PS3="Enter your choice: "
options=("Basic Install (Most Common)" "Install with SSL (More Secure)" "Fast Sync Enabled (Experimental!)" "SSL with Fast Sync" "Quit")
select opt in "${options[@]}"; do
    case $opt in
        "Basic Install (Most Common)")
            echo "== Starting installation"
            sudo bash /opt/banano-node-docker/banano.sh -s
            break
            ;;
        "Install with SSL (More Secure)")
            read -p "Enter your domain: " domain
            read -p "Enter your email: " email
            echo "== Starting installation"
            sudo bash /opt/banano-node-docker/banano.sh -d "$domain" -e "$email" -s
            break
            ;;
        "Fast Sync (Experimental!)")
            echo "== Starting installation"
            sudo bash /opt/banano-node-docker/banano.sh -f
            break
            ;;
        "SSL with Fast Sync (Experimental!)")
            read -p "Enter your domain: " domain
            read -p "Enter your email: " email
            echo "== Starting installation"
            sudo bash /opt/banano-node-docker/banano.sh -d "$domain" -e "$email" -s -f
            break
            ;;
        "Quit")
            echo "Quitting..."
            exit
            ;;
        *) 
            echo "Invalid option. Please try again."
            ;;
    esac
done

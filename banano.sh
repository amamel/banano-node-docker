#!/bin/bash


# ==================================================
# Script Utilities
# ==================================================

# Add the banano-node directory to the PATH variable
export PATH="./banano-node-docker/banano-node/Banano:$PATH"

# goto script dir
cd "$(dirname "$0")"

# Log file path
logFile="script.log"

# Function to log errors
log_error() {
  local error_message="$1"
  echo "[ERROR] $error_message" | tee -a "$logFile"
}

# Check if any errors occurred during script execution
if [[ $? -ne 0 ]]; then
  log_error "An error occurred during script execution. Please refer to the log file '$logFile' for more details."
fi

# Function to check the operating system
check_os() {
  local os=$(uname -s)
  if [[ "$os" != "Linux" ]]; then
    echo "Sorry, '$os' operating system is not yet supported by this script. If you would like to see '$os' operating system supported, please add an issue on Github."
    exit 1
  fi
}

# Script Version
version='1.0'

# Output Variables
red=$(tput setaf 1)            # Set the variable red to the ANSI escape code for red color
green=$(tput setaf 2)          # Set the variable green to the ANSI escape code for green color
yellow=$(tput setaf 3)         # Set the variable yellow to the ANSI escape code for yellow color
purple=$(tput setaf 5)         # Set the variable purple to the ANSI escape code for purple color
bold=$(tput bold)              # Set the variable bold to the ANSI escape code for bold text
reset=$(tput sgr0)             # Set the variable reset to the ANSI escape code to reset text formatting


# Flags & Arguments
quiet='false'                  # Flag: Quiet mode (default: false)
displaySeed='false'            # Flag: Display wallet seed (default: false)
quick_sync='false'             # Flag: Enable fast sync (default: false)
domain=''                      # Argument: Domain name for SSL setup (default: empty)
email=''                       # Argument: Email for Let's Encrypt SSL setup (default: empty)
tag=''                         # Argument: Docker image tag (default: empty)

while getopts 'sqfd:e:t:' flag; do
  case "$flag" in
    s) displaySeed='true' ;;   # Set displaySeed flag to true if -s option is provided
    d) domain="$OPTARG" ;;     # Set domain to the value provided after -d option
    e) email="$OPTARG" ;;      # Set email to the value provided after -e option
    q) quiet='true' ;;         # Set quiet flag to true if -q option is provided
    f) quick_sync='true' ;;    # Set quick_sync flag to true if -f option is provided
    t) tag="$OPTARG" ;;        # Set tag to the value provided after -t option
    *) exit 1 ;;               # Invalid option, exit with error
  esac
done

echo "$@" > settings

# Function to print ASCII art
print_ascii_art() {
if [[ $quiet = 'false' ]]; then
  echo -e "${green} 
  ====================================================================================================${reset}"
  echo -e "${green}${bold} Banano Node Docker ${reset}"
  echo -e "${yellow} https://github.com/amamel/banano-node-docker${reset}"
  echo -e "${purple} Version ${version} ${reset}"
  echo -e "${green} 
  ====================================================================================================${reset}\n"
  echo -e "${yellow}
  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&BG5J?7!~^^^::::::^^^~!7?J5GB&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@&BPJ7!^^::::::::::^^^^^^^:::::::::^^!7YPB&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  @@@@@@@@@@@@@@@@@@@@@@@@@&GY7~:::::::^^~!!7??JJJYYYYYJJ??7!!~^^^:::::^~7YG&@@@@@@@@@@@@@@@@@@@@@@@@@
  @@@@@@@@@@@@@@@@@@@@@@B57^:::::^^!7?Y5PPGGGGGGGGGGGGGBBBBBGGGP5YJ7!~^^::::^75B@@@@@@@@@@@@@@@@@@@@@@
  @@@@@@@@@@@@@@@@@@@BY!:::::^~7J5PGGGGGGGGGGGGGGGGGGGGGGGGGGGBBBBGG5J7~^^^::^!YB@@@@@@@@@@@@@@@@@@@@@
  @@@@@@@@@@@@@@@@&P!:::::^!?5PGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGBBBBGPJ!^^^^:^7P&@@@@@@@@@@@@@@@@@@
  @@@@@@@@@@@@@@#J~::::^!J5GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGBBBBBPY!^^^^:~Y#@@@@@@@@@@@@@@@@
  @@@@@@@@@@@@#J^::::~?5GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGBBBBBBBBPJ~^^^:^J#@@@@@@@@@@@@
  @@@@@@@@@@&Y^:^::~JPGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGBBBBBBBBBBGY!^^^:^Y&@@@@@@@@@@
  @@@@@@@@@P~::^:~JPGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGBBBBBBBBBBBBBBBGJ^^^^:?&@@@@@@@
  @@@@@@@&?::^:^?PGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGBBBBBBBBBBBBBBBBBB?^^^^:?&@@@@@@
  @@@@@@B~:^^^?GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGBBBBBBBBBBBBBBBBBBBB?^^^^^G@@@@@
  @@@@@G^:^^^JGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGBBBBBBBBBBBBBBBBBBBB?^^^^^G@@@@@
  @@@@P^:^^^JGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGBBBBBBBBBBBBBBBBBBBBBP!^^^:!B@@@@
  @@@G^^^^^YGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGBBBBBBBBBBBBBBBBBBBBBBB5^^^^^G@@@
  @@#^:^^^YGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGBBBBGGGGGGGGGGGGGGGGGGBBBBBBBBBBBBBBBBBBBBBBBBBY^^^^~#@@
  @@7:^^:?GGGGGGGGGGGGGGGGGGGGGGGGGPY?77!!!!!!7?JY5PGBBGGGGGGGGGGGGBBBBBBBBBBBBBBBBBBBBBBBBBBBJ^^^^7@@
  @P:^^^!GGGGGGGGGGGGGGGGGGGGGGPY7~^^^^^^^^^^^^^^^^^~7JPGBBGGGGGGGBBBBBBBBBBBBBBBBBBBBBBBBBBBBB!^^^^P@
  &!^^^^YGGGGGGGGGGGGGGGGGGGGP?~^^^^^^^^^^^^^^^^^^^^^^^^!JPBBGGGGBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB5^^^^!&
  P^^^^!GGGGGGGGGGGGGGGGGGGP?^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^75BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB!^^^^P
  ?^^^:JGGGGGGGGGGGGGGGGGBY~^^^^^^^^^^^^^^~~~^^^^^^^^^^^^^^^^7PBBBBBBBBBBPY?7!!!75BBBBBBBBBBBBB#J^^^^?
  ~^^^^5GGGGGGGGGGGGGGGGBJ^^^^^^^^^^^^^~?69.420.19~^^^^^^^^^^^^^^YBBBBBBB5!^^^^^^^:JBBBBBBBBBBBBBBP^^^
  ^^^^^PGGGGGGGGGGGGGGGBJ^^^^^^^^^^^^BENISPPPGGBBPJ7~^^^^^^^^^^^JBBBBP7^^^^^^^^^~GBBBBBBBBBBBBBBG~^^^^
  ^^^^~PGGGGGGGGGGGGGGB5^^^^^^^^^^^7PBB?^^^^^^~!7J5GGPY?!~^^^^^~7BBP?^^^^^^^^^^^Y#BBBBBBBBBBBBBBG~^^^^
  ^^^^^PGGGGGGGGGGGGGGG!^^^^^^^^^75BBBBY^^^^^^^^^^^^!JPBBBGPPPPGBP?^^^^^^^^^^^^?BBBBBBBBBBBBBBBBG~^^^^
  ~^^^^5BGGGGGGGGGGGGBY^^^^^^^^!YBBBBBBB5~^^^^^^^^^^^^^~7YPBBGPJ!^^^^^^^^^^^^^?BBBBBBBBBBBBBBBBBP^^^^!
  ?^^^^JBGGGGGGGGGGGGBP7!!!7?YPGBBBGGGBBBG?^^^^^^^^^^^^^^^^~~^^^^^^^^^^^^^^^~YBBBBBBBBBBBBBBBBB#Y^^^^J
  G^^^^!GGGGGGGGGGGGGGBBBBBBBBBBBGGGGGGBBBBP?~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^7P#BBBBBBBBBBBBBBBBBB!^^^^G
  @!^^^^5BGGGGGGGGGGGGGBBBBBBBGGGGGGGGGBBBBBBGY!~^^^^^^^^^^^^^^^^^^^^^^^~?PBBBBBBBBBBBBBBBBBBB#5^^^^!@
  @P^^^^!GBGGGGGGGGGGGGGGGGGGGGGGGBBBBBBBBBBBBBBGY?!~^^^^^^^^^^^^^^^^~7YG##BBBBBBBBBBBBBBBBBBBB!^^^^P@
  @@?:^^^?BBGGGGGGGGGGGGBBBBBBBBBBBBBBBBBBBBBBBBBBBBGP5J??77!!!77?JYPB##BBBBBBBBBBBBBBBBBBBBB#J^^^^?@@
  @@#~^^^^YBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB###BBBBBBB###BBBBBBBBBBBBBBBBBBBBBBBB#5^^^^~#@@
  @@@B^^^^^YBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB#5^^^^~B@@@
  @@@@G^^^^^YBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBRBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB#Y^^^^~G@@@
  @@@@@G~^^^^?GBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB#BJ^^^^~B@@@@@
  @@@@@@#7^^^^!PBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB#P!^^^^7#@@@@@@
  @@@@@@@&J^^^^^JGBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB#BJ^^^^^Y&@@@@@@@
  @@@@@@@@@G!^^^^~YBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB#BY!^^^^!G@@@@@@@@@
  @@@@@@@@@@&5~^^^^!YGBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB##BY!^^^^~5&@@@@@@@@@@
  @@@@@@@@@@@@&Y~^^^^~JPBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB##BGJ~^^^^~Y&@@@@@@@@@@@@
  @@@@@@@@@@@@@@&5!^^^^^7YGBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB##BGY7^^^^^!5&@@@@@@@@@@@@@@
  @@@@@@@@@@@@@@@@&G?~^^^^^~7YPGBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB###BGPY?~^^^^~?G&@@@@@@@@@@@@@@@@
  @@@@@@@@@@@@@@@@@@@#57~^^^^^~!?J5PGBBB################BBBGP5J?!~^^^^^^!?P#@@@@@@@@@@@@@@@@@@@@@@@@@@
  @@@@@@@@@@@@@@@@@@@@@@#P?~^^^^^^~7YPGBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB#5^^^^~B@@@@@@
  @@@@@@@@@@@@@@@@@@@@@@@@@&B5?!^^^^^^^^~~!7??JYYYY55YYYYJ??7!~~^^^^^^^~!?5B&@@@@@@@@@@@@@@@@@@@@@@@@@
  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@&#G5J7!~^^^^^^^^^^^^^^^^^^^^^^^^^^~!7J5G#&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&#GP5J?7!!~~~~~~~~~~!!7?J5PG#&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  ${reset}"
fi
}


# ===================================================================
# Check and install required tools
# ===================================================================
check_required_tools() {
    # Define required tools
    local requiredTools=("awk" "cmake" "cmake-format" "curl" "git" "g++" "jq" "make" "p7zip-full" "python-dev-is-python3" "ufw" "wget")

    # Check if required tools are installed
    local missingTools=()
    for tool in "${requiredTools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            missingTools+=("$tool")
        fi
    done

    # Install missing tools if any
    if [[ ${#missingTools[@]} -gt 0 ]]; then
        echo "=> ${red}The following tools are required but are not installed: ${missingTools[*]}.${reset}"
        echo "=> ${yellow}Installing missing dependencies...${reset}"

        # Update package lists and upgrade existing packages
        sudo apt-get update && sudo apt-get upgrade

        # Install missing tools
        sudo apt-get install -y "${missingTools[@]}"

        # Install Python 3 pip
        sudo apt install python3-pip

        # Install cmake-format using pip
        sudo pip install cmake-format
    fi
}


# ===================================================================
# Check if Docker is installed, attempt to install if needed
# ===================================================================
check_docker_installation() {
  if ! command -v docker &> /dev/null; then
    echo "=> ${red}Docker is not installed. Installing Docker...${reset}"
    
    # Add Docker PGP key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    
    # Add Docker remote repository
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Update package information
    sudo apt-get update
    
    # Install Docker
    if [[ $quiet = 'false' ]]; then
      sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    else
      sudo apt-get install -y docker-ce docker-ce-cli containerd.io &> /dev/null
    fi
    
    # Check if the installation was successful
    if [ $? -ne 0 ]; then
      echo "${red}=> Failed to install Docker. Please install Docker manually and run the script again.${reset}"
      exit 2
    fi
  else
    echo "=> ${yellow}Docker is already installed.${reset}"
    echo ""
  fi
}


# ===================================================================
# Check if Docker Compose is installed and install it if necessary
# ===================================================================
check_docker_compose_installation() {
  if ! command -v docker-compose &> /dev/null; then
    echo "${red}Docker Compose is not installed. Installing Docker Compose...${reset}"
    
    # Install Docker Compose
    if [[ $quiet = 'false' ]]; then
      curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
      chmod +x /usr/local/bin/docker-compose
    else
      curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose &> /dev/null
      chmod +x /usr/local/bin/docker-compose
    fi
    
    # Check if the installation was successful
    if [ $? -ne 0 ]; then
      echo "${red}Failed to install Docker Compose. Please install Docker Compose manually and run the script again.${reset}"
      exit 2
    fi
  else
    echo "=> ${yellow}Docker Compose is already installed.${reset}"
    echo ""
  fi
}


# ===================================================================
# Check if tag is applied, if not apply latest
# ===================================================================
apply_latest_docker_image_tag() {
  if [[ -z "$tag" ]]; then
    echo "=> ${yellow}No tag specified. Fetching the latest tag from the Docker Hub...${reset}"

    # Retrieve the latest tag from the Docker Hub using curl, jq, and grep
    tag=$(curl -s "https://hub.docker.com/v2/repositories/bananocoin/banano/tags" | jq -r '.results[].name' | grep -E "^(latest|V[0-9.]+)$" | sort -rV | head -n1)

    if [[ -z "$tag" ]]; then
      echo "${red}Failed to fetch the latest tag. Please specify a valid tag.${reset}"
      exit 1
    fi

    echo "=> ${yellow}Selected tag:${reset} ${green}$tag${reset}"
    echo ""
  fi
}


# ===================================================================
# Function for fast-syncing the LMDB database
# ===================================================================
quick_sync_lmdb() {
  if [[ $quiet = 'false' ]]; then
    printf "=> ${yellow}Downloading the LMDB database for quick-syncing...${reset}\n"
    wget -O snapshot.ldb ${ledgerDownloadLink_LMDB} -q --show-progress

    printf "=> ${yellow}Placing the database file...${reset} "
    mv snapshot.ldb ./banano-node-docker/banano-node/Banano/
    printf "${green}done.${reset}\n"
    echo ""
  else
    wget -O snapshot.ldb ${ledgerDownloadLink_LMDB} -q
    docker-compose stop banano-node &> /dev/null
    mv snapshot.ldb ./banano-node-docker/banano-node/Banano/
  fi
}


# ===================================================================
# Function for fast-syncing the RocksDB database
# ===================================================================
quick_sync_rocksdb() {
  if [[ $quiet = 'false' ]]; then
    printf "=> ${yellow}Downloading the RocksDB database for fast-syncing...${reset}\n"
    wget -O snapshot.tar.gz ${ledgerDownloadLink_RocksDB} -q --show-progress

    printf "=> ${yellow}Extracting and placing the database files...${reset} "
    tar -xf snapshot.tar.gz -C ./banano-node-docker/banano-node/Banano --strip-components=1
    rm snapshot.tar.gz
    printf "${green}done.${reset}\n"
    echo ""
  else
    wget -O snapshot.tar.gz ${ledgerDownloadLink_RocksDB} -q
    docker-compose stop banano-node &> /dev/null
    tar -xf snapshot.tar.gz -C ./banano-node-docker/banano-node/Banano --strip-components=1
    rm snapshot.tar.gz
  fi
}


# ===================================================================
# Function to handle fast-syncing based on user selection
# ===================================================================
quick_sync() {
  PS3="=> ${green}Please select the database you would like to use for fast-syncing: ${reset}"
  options=("LMDB (Banano node LMDB cutecat backup)" "RocksDB (Banano node v23.0 moonano latest RocksDB backup)" "Exit")

  # Prompt the user to choose the database option
  select opt in "${options[@]}"; do
    case $opt in
      "LMDB ${purple}(Banano node LMDB cutecat backup)${reset}")
        ledgerDownloadLink_LMDB='https://lmdb.cutecat.party/snapshot.ldb'
        quick_sync_lmdb
        break
        ;;
      "RocksDB ${purple}(Banano node v23.0 moonano latest RocksDB backup)${reset}")
        ledgerDownloadLink_RocksDB='https://ledgerfiles.moonano.net/files/latest.tar.gz'
        quick_sync_rocksdb
        break
        ;;
      "Skip")
        echo "=> ${red}Installer stopped by user. Fast-syncing aborted.${reset}"
        echo ""
        exit 1
        ;;
      *) echo "=> ${red}Invalid option. Please select a valid number.${reset}" ;;
    esac
  done
}


# ===================================================================
# Check if quick-sync is enabled
# ===================================================================
optional_quick_sync() {
  if [[ $quick_sync = 'true' ]]; then
    quick_sync
  else
    echo "=> ${yellow}Skipping quick-sync. Quick-syncing is not enabled.${reset}"
    echo ""
  fi
}


# ===================================================================
# Function to check the initial node installation
# ===================================================================
check_initial_node_setup() {
  if [[ $quiet = 'false' ]]; then
    echo "=> ${yellow}Checking initial status...${reset}"
    echo ""
  fi

  # Check if the node mounted directory exists
  if [ -d "./banano-node-docker/banano-node" ] && \
    [ ! -d "./banano-node-docker/banano-node/Banano" ]; then

    if [[ $quiet = 'false' ]]; then
      echo "Unsupported directory structure detected. Migrating files..."
    fi

    # Create the "./banano-node-docker/banano-node/Banano" directory
    echo "${yellow}Create the directory${reset}"
    if mkdir -p ./banano-node-docker/banano-node/Banano; then
      if [[ $quiet = 'false' ]]; then
        echo "Directory created successfully."
      fi

      # Move everything into the subdirectory and suppress the error about itself
      echo "${yellow}Move everything into the subdirectory${reset}"
      if mv ./banano-node-docker/banano-node/* ./banano-node-docker/banano-node/Banano/ &> /dev/null; then
        if [[ $quiet = 'false' ]]; then
          echo "File migration done."
        fi
      else
        echo "File migration failed."
        return 1
      fi
    else
      echo "Directory creation failed."
      return 1
    fi

    if [[ $quiet = 'false' ]]; then
      echo ""
    fi
  fi
}

# Call the function to check initial node installation and handle errors
if ! check_initial_node_setup; then
  echo "Initial node setup check failed."
  exit 1
fi


# ===================================================================
# Function to spin up Docker Containers
# ===================================================================
spin_up_and_configure_docker_stack() {
  # Check if quiet mode is disabled
  if [[ $quiet = 'false' ]]; then
    echo "=> ${yellow}Pulling images and spinning up containers...${reset}"
    echo ""
  fi

  # Create the Docker network for Banano node
  docker network create banano-node-network &> /dev/null

  local docker_compose_file

  if [[ $domain ]]; then
    if [[ $tag ]]; then
      # Replace the image tag in the docker-compose.letsencrypt.yml file
      sed -i -e "s/    image: bananocoin\/banano:.*/    image: bananocoin\/banano:$tag/g" docker-compose.letsencrypt.yml
    fi

    # Set the VIRTUAL_HOST, LETSENCRYPT_HOST, and DEFAULT_HOST values in docker-compose.letsencrypt.yml
    sed -i -e "s/           - VIRTUAL_HOST=.*/          - VIRTUAL_HOST=$domain/g" docker-compose.letsencrypt.yml
    sed -i -e "s/           - LETSENCRYPT_HOST=.*/      - LETSENCRYPT_HOST=$domain/g" docker-compose.letsencrypt.yml
    sed -i -e "s/           - DEFAULT_HOST=.*/          - DEFAULT_HOST=$domain/g" docker-compose.letsencrypt.yml

    if [[ $email ]]; then
      # Set the LETSENCRYPT_EMAIL value in docker-compose.letsencrypt.yml
      sed -i -e "s/       - LETSENCRYPT_EMAIL=.*/     - LETSENCRYPT_EMAIL=$email/g" docker-compose.letsencrypt.yml
    fi

    docker_compose_file="docker-compose.letsencrypt.yml"
  else
    if [[ $tag ]]; then
      # Replace the image tag in the docker-compose.yml file
      sed -i -e "s/    image: bananocoin\/banano:.*/    image: bananocoin\/banano:$tag/g" docker-compose.yml
    fi

    docker_compose_file="docker-compose.yml"
  fi

  if [[ $quiet = 'false' ]]; then
    # Start the containers in detached mode with the specified docker-compose file
    docker-compose -f "$docker_compose_file" up -d
  else
    # Start the containers in detached mode with the specified docker-compose file silently
    docker-compose -f "$docker_compose_file" up -d &> /dev/null
  fi

  if [ $? -ne 0 ]; then
    # Check if any errors occurred during container startup
    echo "=> ${red}Encountered errors during container initialization. Please refer to the preceding log for detailed instructions on resolving the issues.${reset}"
    echo ""
    exit 2
  fi
}




# ===================================================================
# Function to wait for Banano node initialization
# ===================================================================
wait_for_node_to_initialize() {
  if [[ $quiet = 'false' ]]; then
    echo "=> ${yellow}Awaiting full initialization of the Banano Node. Please wait while the process completes.${reset}"
  fi

  while ! curl -s -d '{"action": "version"}' 127.0.0.1:7072 | grep -q "rpc_version"; do
    sleep 1s
  done

  if [[ $quiet = 'false' ]]; then
    echo "=> ${yellow}Banano Node initialization complete.${reset}"
    echo ""
  fi
}



# ===================================================================
# Function to set Banano Node aliases and related aliases based on the current shell (Zsh or Bash)
# ===================================================================
set_banano_node_alias() {
  local shell_aliases_file

  # Detect the current shell
  if [ -n "$ZSH_VERSION" ]; then
    shell_aliases_file="$HOME/.zsh_aliases"
  elif [ -n "$BASH_VERSION" ]; then
    shell_aliases_file="$HOME/.bash_aliases"
  else
    echo "${yellow}Unsupported shell. Unable to set aliases.${reset}"
    return 1
  fi

  # Check if banano-node alias is already present in the shell aliases file
  if ! grep -q 'banano-node' "$shell_aliases_file"; then
    local nodeExec="banano-node"  # Replace with the actual Banano Node executable if needed

    local aliases=(
      "banano-node='${nodeExec}'"                               # Alias for banano-node
      "banano-rpc='banano-node --rpc'"                          # Alias for banano-rpc
      "banano-wallet='banano-node --wallet'"                    # Alias for banano-wallet
      "banano-status='banano-node --status'"                    # Alias for banano-status
      "banano-restart='banano-node --stop && banano-node --daemon'"   # Alias for banano-restart
      "banano-update='banano-node --update'"                    # Alias for banano-update
      "banano-logs='tail -f /var/log/banano/banano_node.log'"   # Alias for banano-logs

      # Additional aliases for Banano Wallet RPCs
      "banano-account-create='banano-wallet --rpc --command account_create'"
      "banano-account-list='banano-wallet --rpc --command account_list'"
      "banano-account-remove='banano-wallet --rpc --command account_remove'"
      "banano-account-rename='banano-wallet --rpc --command account_rename'"
      "banano-account-history='banano-wallet --rpc --command account_history'"
      "banano-account-info='banano-wallet --rpc --command account_info'"
      "banano-account-move='banano-wallet --rpc --command account_move'"
      "banano-account-key='banano-wallet --rpc --command account_key'"
      "banano-account-get='banano-wallet --rpc --command account_get'"
      "banano-account-forks='banano-wallet --rpc --command account_forks'"
      "banano-account-balance-total='banano-wallet --rpc --command account_balance_total'"
      "banano-account-representative='banano-wallet --rpc --command account_representative'"
      "banano-account-weight='banano-wallet --rpc --command account_weight'"
      "banano-account-weights='banano-wallet --rpc --command account_weights'"
      "banano-account-confirmations='banano-wallet --rpc --command account_confirmations'"
      "banano-account-create-work='banano-wallet --rpc --command account_create_work'"

      # Additional aliases for Banano Wallet
      "banano-balance='banano-wallet info --balance'"           # Alias for banano-balance
      "banano-accounts='banano-wallet accounts'"                # Alias for banano-accounts
      "banano-send='banano-wallet send'"                        # Alias for banano-send
      "banano-import='banano-wallet import'"                    # Alias for banano-import
      "banano-export='banano-wallet export'"                    # Alias for banano-export
      "banano-history='banano-wallet history'"                  # Alias for banano-history
      "banano-receive='banano-wallet receive'"                  # Alias for banano-receive
      "banano-representatives='banano-wallet representatives'"  # Alias for banano-representatives
      "banano-delegators='banano-wallet delegators'"            # Alias for banano-delegators
      "banano-account-info='banano-wallet account_info'"        # Alias for banano-account-info
      "banano-block-info='banano-wallet block_info'"            # Alias for banano-block-info
      "banano-block-count='banano-wallet block_count'"          # Alias for banano-block-count
      "banano-work-generate='banano-wallet work_generate'"      # Alias for banano-work-generate

      # Additional aliases for Banano Node Monitor
      "banano-monitor='php banano-node-monitor/nanoNodeMonitor/config.php'"   # Alias for banano-monitor

      # Additional aliases for Banano commands
      "banano-process='banano-wallet process'"                  # Alias for banano-process
      "banano-broadcast='banano-wallet broadcast'"              # Alias for banano-broadcast
      "banano-account-create='banano-wallet account_create'"    # Alias for banano-account-create
      "banano-account-remove='banano-wallet account_remove'"    # Alias for banano-account-remove
      "banano-account-move='banano-wallet account_move'"        # Alias for banano-account-move
      "banano-account-rename='banano-wallet account_rename'"    # Alias for banano-account-rename
      "banano-account-history='banano-wallet account_history'"  # Alias for banano-account-history
      "banano-account-key='banano-wallet account_key'"          # Alias for banano-account-key
      "banano-receive-minimum='banano-wallet receive_minimum'"  # Alias for banano-receive-minimum
      "banano-proof-of-work-validate='banano-wallet proof_of_work_validate'"  # Alias for banano-proof-of-work-validate

      # Additional aliases related to Banano node seed (Always use caution when working with your seed)
      "banano-display-seed='banano-wallet seed --show'"         # Alias for banano-display-seed
      "banano-generate-seed='banano-wallet seed --generate'"    # Alias for banano-generate-seed
      "banano-export-seed='banano-wallet seed --export'"        # Alias for banano-export-seed
      "banano-import-seed='banano-wallet seed --import'"        # Alias for banano-import-seed
      "banano-change-seed='banano-wallet seed --change'"        # Alias for banano-change-seed
      "banano-validate-seed='banano-wallet seed --validate'"    # Alias for banano-validate-seed
    )

    # Add aliases to the shell aliases file
    for alias_command in "${aliases[@]}"; do
      echo "alias $alias_command" >> "$shell_aliases_file"
    done

    # Source the shell configuration file to apply the changes
    if [ -n "$ZSH_VERSION" ]; then
      source "$HOME/.zshrc"
    elif [ -n "$BASH_VERSION" ]; then
      source "$HOME/.bashrc"
    fi
  fi
}



# ================================================================================
# Function to check if a Banano wallet exists and generate a new one if necessary
# ================================================================================
wallet_check_and_generation() {
  local nodeExec="./banano-node/Banano"  # Replace with the actual Banano Node executable if needed

  # Check if wallet already exists
  existingWallet="$(${nodeExec} --wallet_list | grep 'Wallet ID' | awk '{ print $NF}')"

  if [[ ! $existingWallet ]]; then
    [[ $quiet = 'false' ]] && printf "=> ${yellow}No wallet found. Generating a new one... ${reset}"

    walletId=$(${nodeExec} --wallet_create | tr -d '\r')
    address="$(${nodeExec} --account_create --wallet=$walletId | awk '{ print $NF}')"

    [[ $quiet = 'false' ]] && printf "${green}done.${reset}\n\n"
  else
    [[ $quiet = 'false' ]] && echo "=> ${yellow}Existing wallet found.${reset}"
    [[ $quiet = 'false' ]] && echo ''

    address="$(${nodeExec} --wallet_list | grep 'ban_' | awk '{ print $NF}' | tr -d '\r')"
    walletId=$(echo $existingWallet | tr -d '\r')
  fi

  if [[ $quiet = 'false' && $displaySeed = 'true' ]]; then
    seed=$(${nodeExec} --wallet_decrypt_unsafe --wallet=$walletId | grep 'Seed' | awk '{ print $NF}' | tr -d '\r')
  fi
}




# ================================================================================
# Function to check if the Banano Node Monitor config file exists, 
# fetch a fresh copy if necessary, and configure it
# ================================================================================

configure_banano_node_monitor() {
  if [ ! -f /opt/banano-node-monitor/nanoNodeMonitor/config.php ]; then
    # No existing config file found, fetch a fresh copy
    [[ $quiet = 'false' ]] && echo "=> ${yellow}No existing Banano Node Monitor config file found. Fetching a fresh copy...${reset}"
    if [[ $quiet = 'false' ]]; then
      docker-compose restart banano-node-monitor
    else
      docker-compose restart banano-node-monitor > /dev/null
    fi
  fi

  [[ $quiet = 'false' ]] && printf "=> ${yellow}Configuring Banano Node Monitor... ${reset}"

  # Update the Banano Node RPC IP in the config file
  sed -i -e "s/\/\/ \$bananoNodeRPCIP.*;/\$bananoNodeRPCIP/g" ./banano-node-monitor/nanoNodeMonitor/config.php
  sed -i -e "s/\$bananoNodeRPCIP.*/\$bananoNodeRPCIP = 'banano-node';/g" ./banano-node-monitor/nanoNodeMonitor/config.php

  # Update the Banano Node account in the config file
  sed -i -e "s/\/\/ \$bananoNodeAccount.*;/\$bananoNodeAccount/g" ./banano-node-monitor/nanoNodeMonitor/config.php
  sed -i -e "s/\$bananoNodeAccount.*/\$bananoNodeAccount = '$address';/g" ./banano-node-monitor/nanoNodeMonitor/config.php

  if [[ $domain ]]; then
    # Use the specified domain as the Banano Node name in the config file
    sed -i -e "s/\/\/ \$bananoNodeName.*;/\$bananoNodeName = '$domain';/g" ./banano-node-monitor/nanoNodeMonitor/config.php
  else
    # Use the IP address as the Banano Node name in the config file
    ipAddress=$(curl -s v4.ifconfig.co | awk '{ print $NF}' | tr -d '\r')

    # In case of an IPv6 address, add square brackets
    if [[ $ipAddress =~ .*:.* ]]; then
      ipAddress="[$ipAddress]"
    fi

    sed -i -e "s/\/\/ \$bananoNodeName.*;/\$bananoNodeName = 'banano-node-docker-$ipAddress';/g" ./banano-node-monitor/nanoNodeMonitor/config.php
  fi

  # Set the currency, welcome message, block explorer, theme choice, Banano Node RPC port, and widget type in the config file
  sed -i -e "s/\/\/ \$currency.*;/\$currency = 'banano';/g" ./banano-node-monitor/nanoNodeMonitor/config.php
  sed -i -e "s/\/\/ \$welcomeMsg.*;/\$welcomeMsg = 'Welcome! This node was set up using <a href=\"https:\/\/github.com\/amamel\/banano-node-docker\" target=\"_blank\">Banano Node Docker<\/a>!';/g" ./banano-node-monitor/nanoNodeMonitor/config.php
  sed -i -e "s/\/\/ \$blockExplorer.*;/\$blockExplorer = 'bananocreeper';/g" ./banano-node-monitor/nanoNodeMonitor/config.php
  sed -i -e "s/\/\/ \$themeChoice.*;/\$themeChoice = 'banano';/g" ./banano-node-monitor/nanoNodeMonitor/config.php
  sed -i -e "s/\/\/ \$nanoNodeRPCPort.*;/\$nanoNodeRPCPort = '7072';/g" ./banano-node-monitor/nanoNodeMonitor/config.php
  sed -i -e "s/\/\/ \$widgetType.*;/\$widgetType = 'monkey';/g" ./banano-node-monitor/nanoNodeMonitor/config.php


  # Remove any carriage returns that may have been included by sed replacements
  sed -i -e 's/\r//g' ./banano-node-monitor/nanoNodeMonitor/config.php

  [[ $quiet = 'false' ]] && printf "${green}done.${reset}\n\n"

  # Output success message and relevant information if quiet mode is disabled
  if [[ $quiet = 'false' ]]; then
    echo "${yellow} |=========================================================================================| ${reset}"
    echo "${yellow} | ${green}${bold}Congratulations! Banano Node Docker has been set up successfully!        | ${yellow}| ${reset}"
    echo "${yellow} |=========================================================================================| ${reset}"
    echo "${yellow} | Node public address: ${green}$address${yellow} | ${reset}"
    if [[ $displaySeed = 'true' ]]; then
     echo "${yellow}| Node seed (private):${reset} ${red}$seed${yellow}     | ${reset}"
    fi
    echo "${yellow} |=========================================================================================| ${reset}"

    echo ""

    if [[ $domain ]]; then
      echo "${yellow} Open a browser and navigate to ${green}https://$domain${yellow} to check your monitor."
    else
      echo "${yellow} Open a browser and navigate to ${green}http://$ipAddress${yellow} to check your monitor."
    fi
    echo "${yellow} You can further configure and personalize your monitor by editing the config file,"
    echo "${yellow} located in ${green}banano-node-monitor/nanoNodeMonitor/config.php${yellow}.${reset}"

    echo "${yellow} ================================================================================== ${reset}"
    echo "${purple} || A lot of care and effort has gone into refactoring Banano Node Docker,       || ${reset}"
    echo "${purple} || to make the script easily configurable and accessible for others.            || ${reset}"
    echo "${purple} || Your support is invaluable in sustaining this project.                       || ${reset}"
    echo "${purple} || Thank you for being a part of it!                                            || ${reset}"
    echo "${yellow} ================================================================================== ${reset}"
    echo "${yellow}${bold} Support Project : ${green}ban_114i44aggu9a31gymt4pj1ztuk5prn76ejej1baw9ixr9j5z4djngmn4k6tm ${reset}"
    echo "${yellow} ================================================================================== ${reset}"
  fi
}


# ================================================================================
# Function to run all node functions
# ================================================================================
main() {
  # ...

  # Run each function and check the return value
  check_os
  if [ $? -ne 0 ]; then
    echo "Error: Failed to check the operating system."
    exit 1
  fi

  print_ascii_art

  check_required_tools
  if [ $? -ne 0 ]; then
    echo "Error: Failed to check for required system tools."
    exit 1
  fi

  check_docker_installation
  if [ $? -ne 0 ]; then
    echo "Error: Docker installation check failed."
    exit 1
  fi

  check_docker_compose_installation
  if [ $? -ne 0 ]; then
    echo "Error: Docker Compose installation check failed."
    exit 1
  fi

  apply_latest_docker_image_tag
  if [ $? -ne 0 ]; then
    echo "Error: Failed to apply the latest Docker image tag."
    exit 1
  fi

  optional_quick_sync
  if [ $? -ne 0 ]; then
    echo "Error: Failed to select Node Database Type."
    exit 1
  fi

  check_initial_node_setup
  if [ $? -ne 0 ]; then
    echo "Error: Initial node setup check failed."
    exit 1
  fi

  spin_up_and_configure_docker_stack
  if [ $? -ne 0 ]; then
    echo "Error: Failed to spin up and configure and Docker containers."
    exit 1
  fi

  wait_for_node_to_initialize
  if [ $? -ne 0 ]; then
    echo "Error: Failed to wait for node initialization."
    exit 1
  fi

  set_banano_node_alias
  if [ $? -ne 0 ]; then
    echo "Error: Failed to set Banano node alias."
    exit 1
  fi

  wallet_check_and_generation
  if [ $? -ne 0 ]; then
    echo "Error: Failed to check and generate a wallet."
    exit 1
  fi

  configure_banano_node_monitor
  if [ $? -ne 0 ]; then
    echo "Error: Failed to configure Banano Node Monitor."
    exit 1
  fi

  # ...
}

# Execute main function
main


# ================================================================================
# Check if the script finished successfully and call the function
# ================================================================================
if [ $? -eq 0 ]; then
  echo "${green}${bold}Completed${reset}"
  press_any_key  # Exit Script
fi


# ================================================================================
# Function to display "Press any key to close" message
# ================================================================================
press_any_key() {
    echo ""
    echo ""
    echo ""
    echo ""
    echo "=> ${green}${bold}Banano Node Docker finished successfully. Press any key to close.${reset}"
    read -n 1 -s -r -p ""  # Wait for user input of any key
}

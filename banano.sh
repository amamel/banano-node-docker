#!/bin/bash

# Log file path
logFile="script.log"

# Function to log errors
log_error() {
  local error_message="$1"
  echo "[ERROR] $error_message" | tee -a "$logFile"
}

# Check if the script finished successfully and call the function
if [ $? -eq 0 ]; then
    press_any_key
fi

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
bold=$(tput bold)              # Set the variable bold to the ANSI escape code for bold text
reset=$(tput sgr0)             # Set the variable reset to the ANSI escape code to reset text formatting

# Flags & Arguments
quiet='false'                  # Flag: Quiet mode (default: false)
displaySeed='false'            # Flag: Display wallet seed (default: false)
fastSync='false'               # Flag: Enable fast sync (default: false)
domain=''                      # Argument: Domain name for SSL setup (default: empty)
email=''                       # Argument: Email for Let's Encrypt SSL setup (default: empty)
tag=''                         # Argument: Docker image tag (default: empty)

while getopts 'sqfd:e:t:' flag; do
  case "$flag" in
    s) displaySeed='true' ;;   # Set displaySeed flag to true if -s option is provided
    d) domain="$OPTARG" ;;     # Set domain to the value provided after -d option
    e) email="$OPTARG" ;;      # Set email to the value provided after -e option
    q) quiet='true' ;;         # Set quiet flag to true if -q option is provided
    f) fastSync='true' ;;      # Set fastSync flag to true if -f option is provided
    t) tag="$OPTARG" ;;        # Set tag to the value provided after -t option
    *) exit 1 ;;               # Invalid option, exit with error
  esac
done

echo "$@" > settings

# Function to print ASCII art
print_ascii_art() {
if [[ $quiet = 'false' ]]; then
  echo -e "${green} ------------------------------------${reset}"
  echo -e "${green}${bold} Banano Node Docker ${version}${reset}"
  echo -e "${yellow} https://github.com/amamel/banano-node-docker${reset}"
  echo -e "${green} ------------------------------------${reset}\n"
  echo "
  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&BG5J?7!~^^^::::::^^^~!7?J5GB&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&BPJ7!^^::::::::::^^^^^^^:::::::::^^!7YPB&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@&GY7~:::::::^^~!!7??JJJYYYYYJJ??7!!~^^^:::::^~7YG&@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@B57^:::::^^!7?Y5PPGGGGGGGGGGGGGBBBBBGGGP5YJ7!~^^::::^75B@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@BY!:::::^~7J5PGGGGGGGGGGGGGGGGGGGGGGGGGGGBBBBGG5J7~^^^::^!YB@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@&P!:::::^!?5PGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGBBBBGPJ!^^^^:^7P&@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@#J~::::^!J5GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGBBBBBPY!^^^^:~Y#@@@@@@@@@@@@@@
@@@@@@@@@@@@#J^::::~?5GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGBBBBBBBBPJ~^^^:^J#@@@@@@@@@@@@
@@@@@@@@@@&Y^:^::~JPGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGBBBBBBBBBBGY!^^^:^Y&@@@@@@@@@@
@@@@@@@@@P~::^:~JPGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGBBBBBBBBBBBBBBBGJ^^^^:?&@@@@@@@
@@@@@@@&?::^:^?PGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGBBBBBBBBBBBBBBBBBB?^^^^:?&@@@@@@@
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
~^^^^5GGGGGGGGGGGGGGGGBJ^^^^^^^^^^^^^~?69420B7~^^^^^^^^^^^^^^YBBBBBBB5!^^^^^^^:JBBBBBBBBBBBBBBP^^^^~
^^^^^PGGGGGGGGGGGGGGGBJ^^^^^^^^^^^^75GGPPPPGGBBPJ7~^^^^^^^^^^^JBBBBP7^^^^^^^^^~GBBBBBBBBBBBBBBG~^^^^
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
@@@@G^^^^^YBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBRBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB#Y^^^^~G@@@@
@@@@@G~^^^^?GBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB#BJ^^^^~B@@@@@
@@@@@@#7^^^^!PBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB#P!^^^^7#@@@@@@
@@@@@@@&J^^^^^JGBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB#BJ^^^^^Y&@@@@@@@
@@@@@@@@@G!^^^^~YBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB#BY!^^^^!G@@@@@@@@@
@@@@@@@@@@&5~^^^^!YGBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB##BY!^^^^~5&@@@@@@@@@@
@@@@@@@@@@@@&Y~^^^^~JPBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB##BGJ~^^^^~Y&@@@@@@@@@@@@
@@@@@@@@@@@@@@&5!^^^^^7YGBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB##BGY7^^^^^!5&@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@&G?~^^^^^~7YPGBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB###BGPY?~^^^^~?G&@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@#57~^^^^^~!?J5PGBBB################BBBGP5J?!~^^^^^^!?P#@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@#P?~^^^^^^~7YPGBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB#5^^^^~B@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@&B5?!^^^^^^^^~~!7??JYYYY55YYYYJ??7!~~^^^^^^^~!?5B&@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&#G5J7!~^^^^^^^^^^^^^^^^^^^^^^^^^^~!7J5G#&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&#GP5J?7!!~~~~~~~~~~!!7?J5PG#&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
fi
}










# Check and install required tools
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
        echo "${red}The following tools are required but are not installed: ${missingTools[*]}.${reset}"
        echo "${yellow}Installing missing dependencies...${reset}"

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











# Check if Docker is installed, attempt to install if needed
check_docker_installation() {
  if ! command -v docker &> /dev/null; then
    echo "${red}Docker is not installed. Installing Docker...${reset}"
    
    # Add Docker PGP key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    
    # Add Docker remote repository
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Update package information
    sudo apt-get update
    
    # Check if quiet mode is disabled
    if [[ $quiet = 'false' ]]; then
        # Install Docker
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    else
        # Install Docker silently
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io &> /dev/null
    fi
    
    # Check if the installation was successful
    if [ $? -ne 0 ]; then
        echo "${red}Failed to install Docker. Please install Docker manually and run the script again.${reset}"
        exit 2
    fi
  else
    echo "Docker is already installed."
  fi
}










# Check if Docker Compose is installed and install it if necessary
check_docker_compose_installation() {
  if ! command -v docker-compose &> /dev/null; then
    echo "${red}Docker Compose is not installed. Installing Docker Compose...${reset}"
    
    # Check if quiet mode is disabled
    if [[ $quiet = 'false' ]]; then
        # Install Docker Compose
        curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        chmod +x /usr/local/bin/docker-compose
    else
        # Install Docker Compose silently
        curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose &> /dev/null
        
        # Make it executable
        chmod +x /usr/local/bin/docker-compose

        # Make it a global
        ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
    fi
    
    # Check if the installation was successful
    if [ $? -ne 0 ]; then
        echo "${red}Failed to install Docker Compose. Please install Docker Compose manually and run the script again.${reset}"
        exit 2
    fi
  else
    echo "Docker Compose is already installed."
  fi
}










# Check if tag is applied, if not apply latest
apply_latest_docker_image_tag() {
  if [[ -z "$tag" ]]; then
    echo "${yellow}No tag specified. Fetching the latest tag from the Docker Hub...${reset}"

    # Retrieve the latest tag from the Docker Hub using curl, jq, and grep
    tag=$(curl -s https://hub.docker.com/r/bananocoin/banano/tags | jq -r '.[].name' | grep -E "^[0-9.]+$" | sort -rV | head -n1)

    echo "${green}Selected tag: $tag${reset}"
  fi
}











# Perform fast-sync if enabled
optional_fast_sync() {
  # Fast-Sync data sources
  ledgerDownloadLink_LMDB='https://lmdb.cutecat.party/snapshot.ldb'
  ledgerDownloadLink_RocksDB='https://ledgerfiles.moonano.net/files/latest.tar.gz'

  if [[ $fastSync == 'true' ]]; then
    echo "Fast-syncing enabled. Downloading the latest ledger file..."

    # Prompt user to select the database for fast-syncing
    echo "Please select the database you would like to use for fast-syncing:"
    echo "1. LMDB (Banano node LMDB cutecat backup)"
    echo "2. RocksDB (Banano node v23.0 moonano latest RocksDB backup)"
    read -rp "(Default: LMDB) [1]LMDB [2]RocksDB [E]xit: " dbChoice

    case $dbChoice in
        1)
            # User selected LMDB
            ledgerDownloadLink=$ledgerDownloadLink_LMDB
            fileExtension=".gz"
            ;;
        2)
            # User selected RocksDB
            ledgerDownloadLink=$ledgerDownloadLink_RocksDB
            fileExtension=".tar.gz"
            ;;
        *)
            # User chose to exit
            echo "${red}Installer stopped by user. Fast-syncing aborted.${reset}"
            exit 1
            ;;
    esac

    # Download the latest ledger file for fast-syncing
    if [[ $quiet = 'false' ]]; then
        # Display download progress if not in quiet mode
        printf "=> ${yellow}Downloading the latest ledger file for fast-syncing...${reset}\n"
        wget -O snapshot.ldb$fileExtension "$ledgerDownloadLink" -q --show-progress
        printf "=> ${yellow}Placing the file...${reset} "
    else
        # Download ledger file silently in quiet mode
        wget -O snapshot.ldb$fileExtension "$ledgerDownloadLink" -q
        docker-compose stop banano-node &> /dev/null
    fi

    # Extract the files if needed
    if [[ $fileExtension == ".gz" ]]; then
        # Extract .gz file
        gunzip -c snapshot.ldb.gz > snapshot.ldb
        rm snapshot.ldb.gz
    elif [[ $fileExtension == ".tar.gz" ]]; then
        # Extract .tar.gz file
        tar -xf snapshot.ldb.tar.gz -C ./banano-node/Banano --strip-components=1
        rm snapshot.ldb.tar.gz
    fi

    printf "${green}done.${reset}\n"
    echo ""
  fi
}











# Function to check the initial node setup
check_initial_node_setup() {
  if [[ $quiet = 'false' ]]; then
    echo "=> ${yellow}Checking initial status...${reset}"
    echo ""
  fi

  # Check if the "./banano-node" directory exists and "./banano-node/Banano" directory does not exist
  if [ -d "./banano-node" ] && [ ! -d "./banano-node/Banano" ]; then
    # If the "./banano-node" directory exists but "./banano-node/Banano" does not exist,
    # perform the following steps:

    # Check if quiet mode is disabled
    if [[ $quiet = 'false' ]]; then
      printf "${reset}Detected an unsupported directory structure, updating file organization ... "
    fi

    # Create the "./banano-node/Banano" directory
    mkdir -p ./banano-node/Banano

    # Move everything into the subdirectory and suppress the error about itself
    mv ./banano-node/* ./banano-node/Banano/ &> /dev/null

    # Check if quiet mode is disabled
    if [[ $quiet = 'false' ]]; then
      printf "${green}done.\n${reset}"
      echo ""
    fi
  fi
}









# Function to spin up the appropriate stack
spin_up_docker_stack() {
  # Check if quiet mode is disabled
  if [[ $quiet = 'false' ]]; then
    echo "=> ${yellow}Pulling images and spinning up containers...${reset}"
    echo ""
  fi

  # Create the Docker network for Banano node
  docker network create banano-node-network &> /dev/null
}










# Function to configure Docker Compose and start containers
configure_and_start_docker_containers () {
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
    echo "${red}Encountered errors during container initialization. Please refer to the preceding log for detailed instructions on resolving the issues.${reset}"
    exit 2
  fi
}










# Function to wait for Banano node initialization
wait_for_node_to_initialize() {
  if [[ $quiet = 'false' ]]; then
    # Print a message to indicate that the script is waiting for the Banano node to initialize
    echo ""
    printf "=> ${yellow}Awaiting full initialization of the Banano node. Please wait while the process completes. "
  fi

  # Keep checking the Banano node's version until it responds with the expected JSON
  while ! curl -s -d '{"action": "version"}' 127.0.0.1:7072 | grep -q "rpc_version"; do
    sleep 1s
  done

  if [[ $quiet = 'false' ]]; then
    # Print a message to indicate that the Banano node has finished initializing
    printf "${green}done.${reset}\n\n"
  fi
}




# Function to set Banano Node aliases and related aliases based on the current shell (Zsh or Bash)
set_banano_node_alias() {
  local shell_aliases_file

  # Detect the current shell
  if [ -n "$ZSH_VERSION" ]; then
    shell_aliases_file="$HOME/.zsh_aliases"
  elif [ -n "$BASH_VERSION" ]; then
    shell_aliases_file="$HOME/.bash_aliases"
  else
    echo "Unsupported shell. Unable to set aliases."
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
      "banano-monitor='php ./banano-node-monitor/config.php'"   # Alias for banano-monitor

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





















# Function to check if a wallet exists and generate a new one if necessary
wallet_check_and_generation() {
  existedWallet="$(${nodeExec} --wallet_list | grep 'Wallet ID' | awk '{ print $NF}')"

if [[ ! $existedWallet ]]; then
    [[ $quiet = 'false' ]] && printf "=> ${yellow}No wallet found. Generating a new one... ${reset}"

    walletId=$(${nodeExec} --ban_wallet_create | tr -d '\r')
    address="$(${nodeExec} --ban_account_create --wallet=$walletId | awk '{ print $NF}')"
    
    [[ $quiet = 'false' ]] && printf "${green}done.${reset}\n\n"
else
    [[ $quiet = 'false' ]] && echo "=> ${yellow}Existing wallet found.${reset}"
    [[ $quiet = 'false' ]] && echo ''

    address="$(${nodeExec} --wallet_list | grep 'ban_' | awk '{ print $NF}' | tr -d '\r')"
    walletId=$(echo $existedWallet | tr -d '\r')
fi

if [[ $quiet = 'false' && $displaySeed = 'true' ]]; then
    seed=$(${nodeExec} --wallet_decrypt_unsafe --wallet=$walletId | grep 'Seed' | awk '{ print $NF}' | tr -d '\r')
fi
}










# Function to check if the Banano Node Monitor config file exists, fetch a fresh copy if necessary, and configure it
configure_banano_node_monitor() {
  if [ ! -f ./banano-node-monitor/config.php ]; then
    [[ $quiet = 'false' ]] && echo "=> ${yellow}No existing Banano Node Monitor config file found. Fetching a fresh copy...${reset}"
    if [[ $quiet = 'false' ]]; then
        docker-compose restart banano-node-monitor
    else
        docker-compose restart banano-node-monitor > /dev/null
    fi
fi

[[ $quiet = 'false' ]] && printf "=> ${yellow}Configuring Banano Node Monitor... ${reset}"

sed -i -e "s/\/\/ \$bananoNodeRPCIP.*;/\$bananoNodeRPCIP/g" ./banano-node-monitor/config.php
sed -i -e "s/\$bananoNodeRPCIP.*/\$bananoNodeRPCIP = 'banano-node';/g" ./banano-node-monitor/config.php

sed -i -e "s/\/\/ \$bananoNodeAccount.*;/\$bananoNodeAccount/g" ./banano-node-monitor/config.php
sed -i -e "s/\$bananoNodeAccount.*/\$bananoNodeAccount = '$address';/g" ./banano-node-monitor/config.php

if [[ $domain ]]; then
    sed -i -e "s/\/\/ \$bananoNodeName.*;/\$bananoNodeName = '$domain';/g" ./banano-node-monitor/config.php
else 
    ipAddress=$(curl -s v4.ifconfig.co | awk '{ print $NF}' | tr -d '\r')

    # in case of an ipv6 address, add square brackets
    if [[ $ipAddress =~ .*:.* ]]; then
        ipAddress="[$ipAddress]"
    fi

    sed -i -e "s/\/\/ \$bananoNodeName.*;/\$bananoNodeName = 'banano-node-docker-$ipAddress';/g" ./banano-node-monitor/config.php
fi

sed -i -e "s/\/\/ \$welcomeMsg.*;/\$welcomeMsg = 'Welcome! This node was setup using <a href=\"https:\/\/github.com\/lephleg\/banano-node-docker\" target=\"_blank\">Banano Node Docker<\/a>!';/g" ./banano-node-monitor/config.php
sed -i -e "s/\/\/ \$blockExplorer.*;/\$blockExplorer = 'banano';/g" ./banano-node-monitor/config.php

# remove any carriage returns may have been included by sed replacements
sed -i -e 's/\r//g' ./banano-node-monitor/config.php

[[ $quiet = 'false' ]] && printf "${green}done.${reset}\n\n"
}













# Function to output success message and relevant information if quiet mode is disabled
output_success_message() {
  if [[ $quiet = 'false' ]]; then
    echo "${yellow} |=========================================================================================| ${reset}"
    echo "${yellow} | ${green}${bold}Congratulations! Banano Node Docker has been setup successfully!           ${yellow}| ${reset}"
    echo "${yellow} |=========================================================================================| ${reset}"
    echo "${yellow} | Node account address: ${green}$address${yellow} | ${reset}"
    if [[ $displaySeed = 'true' ]]; then
        echo "${yellow} | Node wallet seed: ${red}$seed${yellow}      | ${reset}"
    fi
    echo "${yellow} |=========================================================================================| ${reset}"

    echo ""

    if [[ $domain ]]; then
        echo "${yellow} Open a browser and navigate to ${green}https://$domain${yellow} to check your monitor."
    else
        echo "${yellow} Open a browser and navigate to ${green}http://$ipAddress${yellow} to check your monitor."
    fi
    echo "${yellow} You can further configure and personalize your monitor by editing the config file located in ${green}banano-node-monitor/config.php${yellow}.${reset}"

    echo "${yellow} ================================================================================== ${reset}"
    echo "${yellow} || A tremendous amount of care and effort has gone into refactoring             || ${reset}"
    echo "${yellow} || Banano Node Docker, to make it easily configurable and accessible for others.|| ${reset}"
    echo "${yellow} || Your support is invaluable in sustaining this project.                       || ${reset}"
    echo "${yellow} || Thank you for being a part of it!                                            || ${reset}"
    echo "${yellow} ================================================================================== ${reset}"
    echo "${yellow} Feed MonKey Dev : ban_114i44aggu9a31gymt4pj1ztuk5prn76ejej1baw9ixr9j5z4djngmn4k6tm ${reset}"
    echo "${yellow} ================================================================================== ${reset}"

  fi
}

# Function to display "Press any key to close" message
press_any_key() {
    echo "Banano Node Docker finished successfully. Press any key to close."
    read -n 1 -s -r -p ""  # Wait for user input of any key
}










# Function to run all node functions
main() {
  echo "Starting Banano Node Docker Setup Script..."
  echo "==========================================="

  echo "Checking the operating system..."
  check_os                                              # Check the operating system
  print_ascii_art                                       # Print ASCII art

  echo "Checking for required system tools..."
  check_required_tools                                  # Check for required tools to run script

  echo "Checking Docker installation..."
  check_docker_installation                             # Check Docker installation

  echo "Checking Docker Compose installation..."
  check_docker_compose_installation                     # Check Docker Compose installation

  echo "Applying the latest Docker image tag..."
  apply_latest_docker_image_tag                         # Apply the latest Docker image tag

  echo "Enabling fast sync..."
  optional_fast_sync                                    # Enable fast sync

  echo "Checking initial setup..."
  check_initial_node_setup                              # Check initial setup

  echo "Spinning up the Docker stack..."
  spin_up_docker_stack                                  # Spin up the Docker stack

  echo "Configuring and starting Docker containers..."
  configure_and_start_docker_containers                 # Configure and start Docker containers

  echo "Waiting for node initialization..."
  wait_for_node_to_initialize                           # Wait for node initialization

  echo "Setting Banano node alias..."
  set_banano_node_alias                                 # Set Banano node alias

  echo "Checking and generating a wallet..."
  wallet_check_and_generation                           # Check and generate a wallet

  echo "Configuring Banano node monitor..."
  configure_banano_node_monitor                         # Configure Banano node monitor

  output_success_message                                # Output success message
  press_any_key                                         # Exit Script
}

# Execute main function
main

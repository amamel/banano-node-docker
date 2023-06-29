#!/bin/bash

#################################################
#  Banano Node Docker                           #
#  https://github.com/amamel/banano-node-docker #
#################################################

# Function to check the operating system
check_os() {
  local os=$(uname -s)
  if [[ "$os" != "Linux" ]]; then
    echo "Sorry, '$os' operating system is not yet supported by this script. If you would like to see '$os' operating system supported, please add an issue on Github."
    exit 1
  fi
}


# Banano Node Docker Script Version
version='1.0'

# Output Variables
red=$(tput setaf 1)            # Set the variable red to the ANSI escape code for red color
green=$(tput setaf 2)          # Set the variable green to the ANSI escape code for green color
yellow=$(tput setaf 3)         # Set the variable yellow to the ANSI escape code for yellow color
purple=$(tput setaf 5)         # Set the variable purple to the ANSI escape code for purple color
bold=$(tput bold)              # Set the variable bold to the ANSI escape code for bold text
reset=$(tput sgr0)             # Set the variable reset to the ANSI escape code to reset text formatting

# Flags & Arguments
quiet=false            # Flag: Quiet mode (default: false)
displaySeed=false      # Flag: Display wallet seed (default: false)
fastSync=false         # Flag: Enable fast sync (default: false)
domain=''              # Argument: Domain name for SSL setup (default: empty)
email=''               # Argument: Email for Let's Encrypt SSL setup (default: empty)
tag=''                 # Argument: Docker image tag (default: empty)

while getopts 'sqfd:e:t:' flag; do
  case "$flag" in
    s) displaySeed=true ;;   # Set displaySeed flag to true if -s option is provided
    d) domain="$OPTARG" ;;   # Set domain to the value provided after -d option
    e) email="$OPTARG" ;;    # Set email to the value provided after -e option
    q) quiet=true ;;         # Set quiet flag to true if -q option is provided
    f) fastSync=true ;;      # Set fastSync flag to true if -f option is provided
    t) tag="$OPTARG" ;;      # Set tag to the value provided after -t option
    *) exit 1 ;;             # Invalid option, exit with error
  esac
done

echo $@ > settings


ascii_art() {
if [[ $quiet = 'false' ]]; then
  echo -e "${green} ================================================================================${reset}"
  echo -e "${green}${bold} Banano Node Docker ${version}${reset}"
  echo -e "${yellow} https://github.com/amamel/banano-node-docker${reset}"
  echo -e "${green} ================================================================================${reset}\n"
  echo "${yellow}
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
~^^^^5GGGGGGGGGGGGGGGGBJ^^^^^^^^^^^^^~?BENIS420^^^^^^^^^^^^^^YBBBBBBB5!^^^^^^^:JBBBBBBBBBBBBBBP^^^^~
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
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&#GP5J?7!!~~~~~~~~~~!!7?J5PG#&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@${reset}"
fi
}
ascii_art


echo "=> ${yellow}Checking for required tools... ${reset}"
verify_tools() {
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
verify_tools


echo "=> ${yellow}Checking for Docker... ${reset}"
verify_docker() {
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
    echo "=> ${green}$(echo -e '\u2713') Docker is already installed.${reset}"
    echo ""
  fi
}
verify_docker

echo "=> ${yellow}Checking for Docker Compose... ${reset}"
verify_docker_compose() {
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
    echo "=> ${green}$(echo -e '\u2713') Docker Compose is already installed.${reset}"
    echo ""
  fi
}
verify_docker_compose


# Fast Syncing
################################################################################
# Note - These links are community supported but are not guaranteed to work.
################################################################################
# Define the fast-sync database download links
ledgerDownloadLink_LMDB='https://lmdb.cutecat.party/snapshot.ldb'
ledgerDownloadLink_RocksDB='https://ledgerfiles.moonano.net/files/latest.tar.gz'

fast_sync_lmdb() {
  if [[ $quiet = 'false' ]]; then
    printf "=> ${yellow}Downloading the LMDB database for fast-syncing...${reset}\n"
    wget -O snapshot.ldb ${ledgerDownloadLink_LMDB} -q --show-progress
  else
    wget -O snapshot.ldb ${ledgerDownloadLink_LMDB} -q
  fi

  printf "=> ${yellow}Moving the database file...${reset} "
  cp -f snapshot.ldb ./banano-node/BananoData/
  printf "${green}done.${reset}\n"
  echo ""
}


fast_sync_rocksdb() {
  if [[ $quiet = 'false' ]]; then
    printf "=> ${yellow}Downloading the RocksDB database for fast-syncing...${reset}\n"
    wget -O latest.tar.gz ${ledgerDownloadLink_RocksDB} -q --show-progress

    printf "=> ${yellow}Extracting and placing the database files...${reset} "
    
    # Create the /rocksdb folder if it doesn't exist
    mkdir -p ./banano-node/BananoData/rocksdb

    tar -xf latest.tar.gz -C ./banano-node/BananoData/rocksdb --strip-components=1
    rm latest.tar.gz
    printf "${green}done.${reset}\n"
    echo ""
  else
    wget -O latest.tar.gz ${ledgerDownloadLink_RocksDB} -q
    docker-compose stop banano-node &> /dev/null

    # Create the /rocksdb folder if it doesn't exist
    mkdir -p ./banano-node/BananoData/rocksdb

    tar -xf latest.tar.gz -C ./banano-node/BananoData/rocksdb --strip-components=1
    rm latest.tar.gz
  fi
}

fast_sync() {
  # Define the menu options using variables
  option1="LMDB"
  option2="RocksDB"
  option3="Exit"

  PS3="=> ${green}Please select the database you would like to use for fast-syncing: ${reset}"
  options=("$option1" "$option2" "$option3")

  # Prompt the user to choose the database option
  select opt in "${options[@]}"; do
    case $opt in
      "$option1")
        fast_sync_lmdb
        break
        ;;
      "$option2")
        fast_sync_rocksdb
        break
        ;;
      "$option3")
        echo "=> ${red}Installer stopped by user. Fast-syncing aborted.${reset}"
        echo ""
        exit 1
        ;;
      *) echo "=> ${red}Invalid option. Please select a valid number.${reset}" ;;
    esac
  done
}

optional_fastSync() {
  if [[ $fastSync = 'true' ]]; then
    fast_sync
  else
    echo "=> ${yellow}Skipping fast-sync. Quick-syncing is not enabled.${reset}"
    echo ""
  fi
}
optional_fastSync



# Determine if this is an initial install
if [[ $quiet = 'false' ]]; then
    echo "=> ${yellow}Checking initial status...${reset}"
    echo ""
fi



# Check if node mounted directory exists
if [ -d "./banano-node" ]; then
    # Check if mounted directory follows the new /root structure
    if [ ! -d "./banano-node/BananoData" ]; then
        if [ ! -d "./banano-node/Banano" ]; then
            [[ $quiet = 'false' ]] && printf "${reset}Unsupported directory structure detected. Migrating files... "

            # Check if Banano directory already exists
            if [ ! -d "./banano-node/BananoData" ]; then
                mkdir ./banano-node/BananoData
            fi

            # Move files only if the Banano directory is empty
            if [ -z "$(ls -A ./banano-node/BananoData)" ]; then
                # Move everything into subdirectory and suppress the error about itself
                mv ./banano-node/* ./banano-node/BananoData/ &> /dev/null
                [[ $quiet = 'false' ]] && printf "${green}done.\n${reset}"
                [[ $quiet = 'false' ]] && echo "done"
                [[ $quiet = 'false' ]] && echo ""
            else
                [[ $quiet = 'false' ]] && printf "${reset}The Banano directory is not empty. Skipping file migration.\n${reset}"
                [[ $quiet = 'false' ]] && echo "done"
                [[ $quiet = 'false' ]] && echo ""
            fi
        fi
    fi
fi




# Spin up the appropriate stack
if [ "$quiet" = 'false' ]; then
  echo "=> ${yellow}Pulling images and spinning up containers...${reset}"
  echo ""
fi

docker network create banano-node-network &> /dev/null

if [ -n "$domain" ]; then
  if [ -n "$tag" ]; then
    echo "=> ${yellow}Selected tag:${reset} ${green}$tag${reset}"
    echo ""
    sed -i "s/image: bananocoin\/banano:.*/image: bananocoin\/banano:$tag/g" docker-compose.letsencrypt.yml
  fi

  sed -i "s/  - VIRTUAL_HOST=.*/  - VIRTUAL_HOST=$domain/g" docker-compose.letsencrypt.yml
  sed -i "s/  - LETSENCRYPT_HOST=.*/  - LETSENCRYPT_HOST=$domain/g" docker-compose.letsencrypt.yml
  sed -i "s/  - DEFAULT_HOST=.*/  - DEFAULT_HOST=$domain/g" docker-compose.letsencrypt.yml

  if [ -n "$email" ]; then
    sed -i "s/  - LETSENCRYPT_EMAIL=.*/  - LETSENCRYPT_EMAIL=$email/g" docker-compose.letsencrypt.yml
  fi

  if [ "$quiet" = 'false' ]; then
    docker-compose -f docker-compose.letsencrypt.yml up -d
  else
    docker-compose -f docker-compose.letsencrypt.yml up -d &> /dev/null
  fi
else
  if [ -n "$tag" ]; then
    echo "=> ${yellow}Selected Dockerhub tag:${reset} ${green}$tag${reset}"
    echo ""
    sed -i "s/image: bananocoin\/banano:.*/image: bananocoin\/banano:$tag/g" docker-compose.yml
  fi

  if [ "$quiet" = 'false' ]; then
    docker-compose up -d
  else
    docker-compose up -d &> /dev/null
  fi
fi

if [ $? -ne 0 ]; then
  echo "${red}Errors were encountered while spinning up the containers. Scroll up for more info on how to fix them.${reset}"
  exit 2
fi



# Check Node Initialization
[[ $quiet = 'false' ]] && echo ""
[[ $quiet = 'false' ]] && printf "=> ${yellow}Waiting for Banano node to fully initialize... "

isRpcLive="$(curl -s -d '{"action": "version"}' 127.0.0.1:7072 | grep "rpc_version")"
while [ ! -n "$isRpcLive" ];
do
    sleep 1s
    isRpcLive="$(curl -s -d '{"action": "version"}' 127.0.0.1:7072 | grep "rpc_version")"
done

[[ $quiet = 'false' ]] && printf "${green}done.${reset}\n\n"

# Determine Node Version
nodeExec="docker exec -it banano-node /usr/bin/bananode"


# Set Aliases for Banano Node CLI
# Function to append alias to shell configuration file if not already present
append_alias() {
    local alias=$1
    local file=$2

    if [ ! -f "$file" ]; then
        touch "$file"
    fi

    if ! grep -q "alias $alias" "$file"; then
        echo "alias $alias" >> "$file"
    fi
}

# Function to check if an alias exists in a file
alias_exists() {
    local alias_name="$1"
    local file_path="$2"
    grep -qF "alias $alias_name" "$file_path"
}

# Banano Alias List
aliases=(
    # Banano Node CLI
    "Benis='${nodeExec}'"  # Formal, respectful, capital B
    "benis='${nodeExec}'"  # CLI b, ok
    "banano-node='${nodeExec}'"  # Alias for Banano Node CLI: Banano Node
    "banano-rpc='banano-node --rpc'"  # Alias for Banano Node CLI: Banano RPC
    "banano-wallet='banano-node --wallet'"  # Alias for Banano Node CLI: Banano Wallet
    "banano-status='banano-node --status'"  # Alias for Banano Node CLI: Banano Node Status
    "banano-restart='banano-node --stop && banano-node --daemon'"  # Alias for Banano Node CLI: Restart Banano Node
    "banano-update='banano-node --update'"  # Alias for Banano Node CLI: Update Banano Node
    "banano-logs='tail -f /var/log/banano/banano_node.log'"  # Alias for Banano Node CLI: View Banano Node Logs

    # Banano Wallet and RPC Commands
    "banano-account-create='banano-wallet --rpc --command account_create'"  # Alias for Banano Wallet: Create a Banano account
    "banano-account-list='banano-wallet --rpc --command account_list'"  # Alias for Banano Wallet: List Banano accounts
    "banano-account-remove='banano-wallet --rpc --command account_remove'"  # Alias for Banano Wallet: Remove a Banano account
    "banano-account-rename='banano-wallet --rpc --command account_rename'"  # Alias for Banano Wallet: Rename a Banano account
    "banano-account-history='banano-wallet --rpc --command account_history'"  # Alias for Banano Wallet: Get account history
    "banano-account-info='banano-wallet --rpc --command account_info'"  # Alias for Banano Wallet: Get account information
    "banano-account-move='banano-wallet --rpc --command account_move'"  # Alias for Banano Wallet: Move an account
    "banano-account-key='banano-wallet --rpc --command account_key'"  # Alias for Banano Wallet: Get the account's public key
    "banano-account-get='banano-wallet --rpc --command account_get'"  # Alias for Banano Wallet: Get the account for a given public key
    "banano-account-forks='banano-wallet --rpc --command account_forks'"  # Alias for Banano Wallet: Get account forks
    "banano-account-balance-total='banano-wallet --rpc --command account_balance_total'"  # Alias for Banano Wallet: Get the total account balance
    "banano-account-representative='banano-wallet --rpc --command account_representative'"  # Alias for Banano Wallet: Get the account representative
    "banano-account-weight='banano-wallet --rpc --command account_weight'"  # Alias for Banano Wallet: Get the account weight
    "banano-account-weights='banano-wallet --rpc --command account_weights'"  # Alias for Banano Wallet: Get the account weights
    "banano-account-confirmations='banano-wallet --rpc --command account_confirmations'"  # Alias for Banano Wallet: Get the account confirmations
    "banano-account-create-work='banano-wallet --rpc --command account_create_work'"  # Alias for Banano Wallet: Create work for an account
    "banano-balance='banano-wallet info --balance'"  # Alias for Banano Wallet: Get the wallet balance
    "banano-accounts='banano-wallet accounts'"  # Alias for Banano Wallet: List wallet accounts
    "banano-send='banano-wallet send'"  # Alias for Banano Wallet: Send Banano from the wallet
    "banano-import='banano-wallet import'"  # Alias for Banano Wallet: Import a Banano wallet
    "banano-export='banano-wallet export'"  # Alias for Banano Wallet: Export a Banano wallet
    "banano-history='banano-wallet history'"  # Alias for Banano Wallet: Get wallet transaction history
    "banano-receive='banano-wallet receive'"  # Alias for Banano Wallet: Receive Banano in the wallet
    "banano-representatives='banano-wallet representatives'"  # Alias for Banano Wallet: List wallet representatives
    "banano-delegators='banano-wallet delegators'"  # Alias for Banano Wallet: List wallet delegators
    "banano-account-info='banano-wallet account_info'"  # Alias for Banano Wallet: Get account information from the wallet
    "banano-block-info='banano-wallet block_info'"  # Alias for Banano Wallet: Get block information from the wallet
    "banano-block-count='banano-wallet block_count'"  # Alias for Banano Wallet: Get the block count from the wallet
    "banano-work-generate='banano-wallet work_generate'"  # Alias for Banano Wallet: Generate work using the wallet
)

# Add aliases to the shell configuration file if they don't already exist
for alias in "${aliases[@]}"; do
    alias_name=$(echo "$alias" | cut -d= -f1)
    config_files=("$HOME/.bash_aliases" "$HOME/.zshrc")
    alias_exists=false

    for file_path in "${config_files[@]}"; do
        if alias_exists "$alias_name" "$file_path"; then
            alias_exists=true
            break
        fi
    done

    if ! $alias_exists; then
        append_alias "$alias" "$HOME/.bash_aliases"
        append_alias "$alias" "$HOME/.zshrc"
    fi
done

# Create .bash_aliases if it doesn't exist
if [ ! -f "$HOME/.bash_aliases" ]; then
    touch "$HOME/.bash_aliases"
fi

# Create .zshrc if it doesn't exist
if [ ! -f "$HOME/.zshrc" ]; then
    touch "$HOME/.zshrc"
fi

# Reload the shell
echo -n "=> ${yellow}Appending Banano node aliases to shell...${reset}"
source "$HOME/.bash_aliases"
source "$HOME/.zshrc"


# Print "done" message
[[ $quiet = 'false' ]] && printf " ${green}done.\n${reset}"



# Update Node Monitor configuration
if [ ! -f ./banano-node-monitor/config.php ]; then
    [[ $quiet = 'false' ]] && echo "=> ${yellow}No existing Banano Node Monitor config file found. Fetching a fresh copy...${reset}"

    if [[ $quiet = 'false' ]]; then
        docker-compose restart banano-node-monitor
    else
        docker-compose restart banano-node-monitor > /dev/null
    fi
fi

[[ $quiet = 'false' ]] && printf "=> ${yellow}Configuring Banano Node Monitor... ${reset}"

##############################################
# Banano Node Monitor Configuration Settings #
##############################################

if [ -f ./banano-node-monitor/config.sample.php ]; then
    # Create the config.php file if it doesn't exist
    cp -n ./banano-node-monitor/config.sample.php ./banano-node-monitor/config.php
fi

# Perform the necessary sed commands
sed -i -e "s/\/\/ \$blockExplorer.*;/\$blockExplorer = 'bananocreeper';/g" ./banano-node-monitor/config.php
sed -i -e "s/\/\/ \$currency.*;/\$currency = 'banano';/g" ./banano-node-monitor/config.php
sed -i -e "s/\/\/ \$nanoNodeAccount.*;/\$nanoNodeAccount/g" ./banano-node-monitor/config.php
sed -i -e "s/\$nanoNodeAccount.*/\$nanoNodeAccount = '$address';/g" ./banano-node-monitor/config.php
sed -i -e "s/\/\/ \$nanoNodeRPCIP.*;/\$nanoNodeRPCIP/g" ./banano-node-monitor/config.php
sed -i -e "s/\$nanoNodeRPCIP.*/\$nanoNodeRPCIP = 'banano-node';/g" ./banano-node-monitor/config.php
sed -i -e "s/\/\/ \$nanoNodeRPCPort.*;/\$nanoNodeRPCPort = '7072';/g" ./banano-node-monitor/config.php
sed -i -e "s/\/\/ \$nodeLocation.*;/\$nodeLocation = 'Jungle';/g" ./banano-node-monitor/config.php
sed -i -e "s/\/\/ \$themeChoice.*;/\$themeChoice = 'banano-dark';/g" ./banano-node-monitor/config.php
sed -i -e "s/\/\/ \$welcomeMsg.*;/\$welcomeMsg = 'Welcome! This node was set up using <a href=\"https:\/\/github.com\/amamel\/banano-node-docker\" target=\"_blank\">Banano Node Docker<\/a>!';/g" ./banano-node-monitor/config.php
sed -i -e "s/\/\/ \$widgetType.*;/\$widgetType = 'monkey';/g" ./banano-node-monitor/config.php

if [[ $domain ]]; then
    sed -i -e "s/\/\/ \$nanoNodeName.*;/\$nanoNodeName = '$domain';/g" ./banano-node-monitor/config.php
else
    ipAddress=$(hostname -I | awk '{print $1}')
    if [[ -z $ipAddress ]]; then
        ipAddress=$(ip addr show | awk '/inet6/{print $2}' | awk -F'/' '{print $1}')
    fi
    sed -i -e "s/\/\/ \$nanoNodeName.*;/\$nanoNodeName = '$ipAddress';/g" ./banano-node-monitor/config.php
fi

# Remove any carriage returns that may have been included by sed replacements
sed -i -e 's/\r//g' ./banano-node-monitor/config.php

[[ $quiet = 'false' ]] && echo "${green}done.${reset}"


if [[ $quiet = 'false' ]]; then

    echo "${yellow} |================================================================================${reset}"
    echo "${yellow} | ${green}${bold}Congratulations! Banano Node Docker has been setup successfully!${reset}"
    echo "${yellow} |================================================================================${reset}"
    echo "${yellow} | ${bold}Node address:${reset} ${green}$address                                  ${reset}"
    echo "${yellow} | ${bold}Wallet ID:${reset} ${green}${walletId}                                  ${reset}"
    echo "${yellow} | ${bold}Please ensure you save the wallet ID and seed.                          ${reset}"
    echo "${yellow} | ${bold}To start managing the wallet, use the following command:                ${reset}"
    echo "${yellow} | ${green}docker exec -it banano-node /usr/bin/bananode --daemon                 ${reset}"
    echo "${yellow} |================================================================================${reset}"    
    if [[ $displaySeed = 'true' ]]; then
        echo "${yellow} | ${bold}SEED:${reset} ${red}${seed}                                         ${reset}"
        echo "${yellow} | ${bold}IMPORTANT:${reset} ${red}Never share your seed. Keep it safe.       ${reset}"
        echo "${yellow} |============================================================================${reset}"
    fi
    
    if [[ $domain ]]; then
        echo "${yellow} Open a browser and navigate to ${green}https://$domain${yellow} to check your monitor."
        echo ""
    else
        echo "${yellow} Open a browser and navigate to ${green}http://$ipAddress${yellow} to check your monitor."
        echo ""
    fi

    echo "${yellow} Configure the node monitor by editing the config file: ${reset}"
    echo "${green} ./banano-node-monitor/config.php${reset}"

    echo "${yellow} =================================================================================${reset}"
    echo "${green} || A lot of care and effort has gone into refactoring Banano Node Docker,      ||${reset}"
    echo "${green} || to make the script easily configurable and accessible for all.              ||${reset}"
    echo "${green} || Your support is invaluable in sustaining this project.                      ||${reset}"
    echo "${green} || Thank you for being a part of it!                                           ||${reset}"
    echo "${yellow} =================================================================================${reset}"
    echo -e " \U0001F34C"
    echo "${yellow}${bold} Support This Project: ${reset}"
    echo "${green} ban_114i44aggu9a31gymt4pj1ztuk5prn76ejej1baw9ixr9j5z4djngmn4k6tm ${reset}"
    echo "${yellow} =================================================================================${reset}"
    echo ""
fi

end() {
    echo -e "\n${green}${bold}Banano Node Docker finished successfully. Press any key to close.${reset}"
    read -n 1 -s -r -p ""  # Wait for user input of any key
}

# ================================================================================
# Check if the script finished successfully and call the function
# ================================================================================
if [ $? -eq 0 ]; then
    echo -e "\n\n\n\n"
    end  # Call the function to display message and wait for keypress
fi
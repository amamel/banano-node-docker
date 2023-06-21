# Banano Node Docker

<div align="center">
    <img src="banano-node-docker.png" alt="Banano Node Docker Logo" width='300px' height='auto'/>
</div>

The Banano Node Docker Bash script automates the setup process for running a Banano node using Docker. It pulls the necessary Docker images, sets up the required configuration, and initializes the Banano node. This makes the process of setting up and configuring a Banano node more efficient and secure.

## Prerequisites

To ensure that the script runs smoothly, please make sure you have Docker and Docker Compose installed on your system. If either of these dependencies is missing, the script will attempt to install them automatically for you.

## Usage

To download or clone the latest release and run the script, follow the instructions below:

For non-SSL setup:
```
cd ~
git clone https://github.com/amamel/banano-node-docker.git
cd ~/banano-node-docker
sudo ./banano.sh -s
```

For SSL setup with Let's Encrypt:
```
cd ~
git clone https://github.com/amamel/banano-node-docker.git
cd ~/banano-node-docker
sudo ./banano.sh -d yourdomain.com -e youremail@yourdomain.com -s
```

### Options (Available Install Option Flags)

| Option    | Description                                                            |
|-----------|------------------------------------------------------------------------|
| `-s`      | Display the seed for the generated wallet.                              |
| `-d <domain>` | Specify a domain name for the Banano node. Enables SSL using Let's Encrypt. |
| `-e <email>`  | Specify an email address for Let's Encrypt SSL certificate notifications.  |
| `-q`      | Run the script in quiet mode, suppressing most of the output.           |
| `-f`      | Enable fast-syncing by downloading the latest ledger files.              |


## Functionality

When the script is executed, it performs a series of functions, which are outlined below:

| Command                               | Step                                 | Description                                                         |
|---------------------------------------|--------------------------------------|---------------------------------------------------------------------|
| `check_os()`                          | Checks the operating system          | Verifies if the script is running on a supported operating system. If not supported, it displays an error message and exits. |
| `check_required_tools()`              | Checks for required tools            | Ensures that all necessary tools are installed to run the script.   |
| `check_docker_installation()`         | Checks Docker installation           | Verifies if Docker is installed on the system.                      |
| `check_docker_compose_installation()` | Checks Docker Compose installation   | Verifies if Docker Compose is installed on the system.              |
| `apply_latest_docker_image_tag()`     | Apply the latest Docker image tag    | Retrieves and applies the latest Docker image tag for the Banano Node. |
| `optional_fast_sync()`                | Optional fast sync                   | Enables the fast synchronization mode for the Banano Node.          |
| `check_initial_node_setup()`          | Checks initial setup                 | Verifies if the initial setup for the Banano Node has been completed. |
| `spin_up_docker_stack()`              | Spins up the Docker stack            | Starts the Docker stack for running the Banano Node.                |
| `configure_start_docker_containers()` | Configure and start Docker containers| Configures and starts the necessary Docker containers for the Banano Node. |
| `wait_for_node_to_initialize()`       | Waits for node to initialize         | Waits for the Banano Node to initialize and become ready.           |
| `set_banano_node_alias()`             | Sets Banano node alias               | Sets the alias for the Banano Node.                                 |
| `wallet_check_and_generation()`       | Wallet check and wallet generation   | Checks if a wallet is already generated and generates a new wallet if needed. |
| `configure_banano_node_monitor()`     | Configures Banano node monitor       | Configures the Banano node monitor for monitoring the node's status. |



## Additional Notes

- The script supports seamless SSL setup using Let's Encrypt if a domain name is provided.
- To expedite the synchronization process, you can enable fast-syncing by using the `-f` option. This allows you to download the latest ledger files for quicker synchronization.
- The script automatically updates the Banano Node Monitor configuration file, including essential information such as the node's RPC IP, account address, node name, and other relevant settings.
- **Important Reminder**: It is crucial to save your wallet seed exactly as it appears in the installer's output. Ensure you securely store this information to maintain access to your wallet.


## Interact with the Banano node Command Line Interface (CLI)

To execute commands from the Banano node's Command Line Interface (CLI), you have two options:

**Option 1: Enter the Banano node container and execute commands directly:**
```
docker exec -it banano-node banano_node <command>
```

**Option 2: Use the shorthand alias provided by the installer for executing Banano node and wallet commands:**
```
banano-node <command>
```

These options provide convenient ways to execute Banano node and wallet commands, giving you flexibility in accessing the Banano node's CLI.

| Alias                        | Description                                                                  |
|------------------------------|------------------------------------------------------------------------------|
| `banano-node`                | Executes Banano node commands.                                               |
| `banano-rpc`                 | Executes Banano node commands with RPC mode enabled.                          |
| `banano-wallet`              | Executes Banano node commands with wallet mode enabled.                       |
| `banano-status`              | Displays the status of the Banano node.                                       |
| `banano-restart`             | Stops and restarts the Banano node daemon.                                    |
| `banano-update`              | Updates the Banano node to the latest version.                                |
| `banano-logs`                | Displays the live logs of the Banano node.                                    |
| `banano-balance`             | Displays the balance of the Banano wallet.                                    |
| `banano-accounts`            | Lists all accounts in the Banano wallet.                                      |
| `banano-send`                | Sends Banano from one account to another.                                     |
| `banano-import`              | Imports a Banano wallet using a seed or private key.                          |
| `banano-export`              | Exports a Banano wallet seed or private key.                                  |
| `banano-history`             | Displays the transaction history of the Banano wallet.                        |
| `banano-receive`             | Generates a new receive address for the Banano wallet.                        |
| `banano-representatives`     | Lists the representatives in the Banano wallet.                               |
| `banano-delegators`          | Lists the delegators in the Banano wallet.                                    |
| `banano-account-info`        | Displays information about a specific Banano account.                         |
| `banano-block-info`          | Displays information about a specific Banano block.                           |
| `banano-block-count`         | Displays the total number of blocks in the Banano blockchain.                 |
| `banano-work-generate`       | Generates proof of work for a Banano block.                                   |
| `banano-monitor`             | Starts the Banano node monitor to monitor the node's status.                  |
| `banano-process`             | Processes pending transactions in the Banano wallet.                          |
| `banano-broadcast`           | Broadcasts pending transactions in the Banano wallet.                         |
| `banano-account-create`      | Creates a new Banano account in the Banano wallet.                            |
| `banano-account-remove`      | Removes a Banano account from the Banano wallet.                              |
| `banano-account-move`        | Moves Banano funds between accounts in the Banano wallet.                     |
| `banano-account-rename`      | Renames a Banano account in the Banano wallet.                                |
| `banano-account-history`     | Displays the transaction history for a specific Banano account.               |
| `banano-account-key`         | Displays the public key of a specific Banano account.                         |
| `banano-receive-minimum`     | Displays the minimum amount required to receive in the Banano wallet.         |
| `banano-proof-of-work-validate` | Validates the proof of work for a specific Banano block.                   |
| `banano-display-seed`        | Displays the seed of the Banano wallet.                                       |
| `banano-generate-seed`       | Generates a new seed for the Banano wallet.                                   |
| `banano-export-seed`         | Exports the seed of the Banano wallet.                                        |
| `banano-import-seed`         | Imports a seed to the Ban

## Recommended Hardware
For optimal performance when running a Banano node, consider the following hardware recommendations:

| Hardware          | Recommendation                                                     |
|-------------------|-------------------------------------------------------------------|
| Processor         | Choose a modern multicore processor with a clock speed of at least 2.5 GHz. For voting nodes and principal nodes, consider having at least 4 CPU cores.  |
| RAM               | Allocate a minimum of 4 GB of RAM, although more is preferable depending on network load and transaction volume.   |
| Storage           | 50 GB of storage space or more, preferably using SSD or NVMe-based storage for faster access and improved performance.  |
| Network Connection| Ensure a stable and reliable internet connection with sufficient bandwidth.  |
| VPS or Dedicated Server | Consider utilizing a datacenter environment, especially SSD VPS providers like Contabo, Hetzner, Vultr, OVH, and DigitalOcean, for optimal performance.  |

These recommendations will help ensure that your Banano node can handle the computational requirements and provide efficient performance for network synchronization, transaction processing, and other node operations.

## Self-configurable Installation

Please check the [wiki](https://github.com/amamel/banano-node-docker/wiki) for more detailed instructions on how to manually self-configure Banano Node Docker.

## Credits
The developers behind the other tools used in this project deserve sincere appreciation for their valuable contributions. If you find these tools useful, consider donating to or contributing to their projects. Your contributions, such as reporting bugs or creating pull requests, can greatly support the continued development and improvement of these tools.
- [Banano](https://github.com/BananoCoin/banano)
- [JrCs/docker-letsencrypt-nginx-proxy-companion](https://github.com/JrCs/docker-letsencrypt-nginx-proxy-companion)
- [jwilder/nginx-proxy](https://github.com/jwilder/nginx-proxy)
- [lephleg/nano-node-docker](https://github.com/lephleg/nano-node-docker)
- [Moonano Fast Sync RocksDB Ledger](https://moonano.net/ledger/)
- [Nanocurrency](https://github.com/nanocurrency/nano-node)
- [Nano Node Monitor](https://github.com/NanoTools/nanoNodeMonitor)
- [v2tec/watchtower](https://github.com/v2tec/watchtower)
- [Very Cute Cat Fast Sync LMBD Ledger](https://lmdb.cutecat.party/)


## Support
If you encounter any issues or have suggestions for improvements, you are encouraged to utilize the "Issues" tab on the GitHub repository. Your feedback is valuable in making this project better. Additionally, you can join the Banano Discord server and navigate to the #frankensteins-lab Banano development channel. It is a great place to engage in conversations, offer suggestions, and receive support from other Banano developers.

If you find this tool helpful and valuable, I kindly ask you to show your support by giving this project a star ⭐️. Your support will help Banano reach more people and make a positive impact. Thank you, and cheers!

## License
This script is released under the [MIT License](https://opensource.org/licenses/MIT).
# Banano Node Docker

<div align="center">
    <img src="banano-node-docker.png" alt="Banano Node Docker Logo" width='300px' height='auto'/>
</div>

The Banano Node Docker Bash script automates the setup process for running a Banano node using Docker. It pulls the necessary Docker images, sets up the required configuration, and initializes the Banano node. This makes the process of setting up and configuring a Banano node more efficient and secure.

## Prerequisites

To ensure that the script runs smoothly, please make sure you have Docker and Docker Compose installed on your system. If either of these dependencies is missing, the script will attempt to install them automatically for you.

## Usage

Download or clone the latest release, open a bash terminal and run the script with the following command:

```
cd ~ && git clone https://github.com/amamel/banano-node-docker.git && cd ~/banano-node-docker
sudo ./banano.sh -d acme.com -e acme@acme.com -s -t V25.1 [options]
```

### Options (Available Install Option Flags)

Certainly! Here's the provided information in a markdown table format:

| Option    | Description                                                            |
|-----------|------------------------------------------------------------------------|
| `-s`      | Display the seed for the generated wallet.                              |
| `-d <domain>` | Specify a domain name for the Banano node. Enables SSL using Let's Encrypt. |
| `-e <email>`  | Specify an email address for Let's Encrypt SSL certificate notifications.  |
| `-q`      | Run the script in quiet mode, suppressing most of the output.           |
| `-f`      | Enable fast-syncing by downloading the latest ledger files.              |


## Functionality

When the script is executed, it performs a series of functions, which are outlined below:

Here's the provided information in a markdown table format:

| Step                                 | Description                                                         |
|--------------------------------------|---------------------------------------------------------------------|
| Checks the operating system          | Verifies if the script is running on a supported operating system. If not supported, it displays an error message and exits. |
| Checks for required tools            | Ensures that all necessary tools are installed to run the script.   |
| Checks Docker installation           | Verifies if Docker is installed on the system.                      |
| Checks Docker Compose installation   | Verifies if Docker Compose is installed on the system.              |
| Apply the latest Docker image tag    | Retrieves and applies the latest Docker image tag for the Banano Node. |
| Optional fast sync                   | Enables the fast synchronization mode for the Banano Node.          |
| Checks initial setup                 | Verifies if the initial setup for the Banano Node has been completed. |
| Spins up the Docker stack            | Starts the Docker stack for running the Banano Node.                |
| Configure and start Docker containers| Configures and starts the necessary Docker containers for the Banano Node. |
| Waits for node to initialize         | Waits for the Banano Node to initialize and become ready.           |
| Sets Banano node alias               | Sets the alias for the Banano Node.                                 |
| Wallet check and wallet generation   | Checks if a wallet is already generated and generates a new wallet if needed. |
| Configures Banano node monitor       | Configures the Banano node monitor for monitoring the node's status. |

Please note that the formatting may differ depending on the platform or text editor used to display the markdown.

After completing these functions, the script outputs a success message. If any errors occur during script execution, they are logged in the specified log file.

## Additional Notes

- If a domain name is provided, the script supports seamless SSL setup using Let's Encrypt.
- To expedite the synchronization process, you can enable fast-syncing by using the -f option. This option allows you to download the latest ledger files for quicker synchronization.
- The Banano Node Monitor configuration file is automatically updated by the script. It includes essential information such as the node's RPC IP, account address, node name, and other relevant settings.
- **As a crucial reminder, it's vital to save your wallet seed exactly as it appears in the output of the installer. Ensure you securely store this information to maintain access to your wallet.**


## Talk to the Node via Banano Node CLI bash alias

To execute commands from the Banano node's Command Line Interface (CLI), you have two options:

1. Enter the Banano node container and execute the commands directly:
   ```
   docker exec -it banano-node banano_node <command>
   ```

2. Utilize the shorthand alias provided by the installer for convenience:
   ```
   banano-node <command>
   ```

| Alias                        | Description                                                                  | Comment                                                                          |
|------------------------------|------------------------------------------------------------------------------|----------------------------------------------------------------------------------|
| `banano-node`                | Executes Banano node commands.                                               | Alias for running Banano node commands.                                          |
| `banano-rpc`                 | Executes Banano node commands with RPC mode enabled.                          | Alias for running Banano node commands with RPC mode.                            |
| `banano-wallet`              | Executes Banano node commands with wallet mode enabled.                       | Alias for running Banano node commands with wallet mode.                         |
| `banano-status`              | Displays the status of the Banano node.                                       | Alias for checking the status of the Banano node.                                |
| `banano-restart`             | Stops and restarts the Banano node daemon.                                    | Alias for stopping and restarting the Banano node daemon.                        |
| `banano-update`              | Updates the Banano node to the latest version.                                | Alias for updating the Banano node to the latest version.                        |
| `banano-logs`                | Displays the live logs of the Banano node.                                    | Alias for viewing the live logs of the Banano node.                              |
| `banano-balance`             | Displays the balance of the Banano wallet.                                    | Alias for checking the balance of the Banano wallet.                             |
| `banano-accounts`            | Lists all accounts in the Banano wallet.                                      | Alias for listing all accounts in the Banano wallet.                             |
| `banano-send`                | Sends Banano from one account to another.                                     | Alias for sending Banano from one account to another.                            |
| `banano-import`              | Imports a Banano wallet using a seed or private key.                          | Alias for importing a Banano wallet using a seed or private key.                 |
| `banano-export`              | Exports a Banano wallet seed or private key.                                  | Alias for exporting a Banano wallet seed or private key.                         |
| `banano-history`             | Displays the transaction history of the Banano wallet.                        | Alias for viewing the transaction history of the Banano wallet.                  |
| `banano-receive`             | Generates a new receive address for the Banano wallet.                        | Alias for generating a new receive address for the Banano wallet.                |
| `banano-representatives`     | Lists the representatives in the Banano wallet.                               | Alias for listing the representatives in the Banano wallet.                      |
| `banano-delegators`          | Lists the delegators in the Banano wallet.                                    | Alias for listing the delegators in the Banano wallet.                           |
| `banano-account-info`        | Displays information about a specific Banano account.                         | Alias for viewing information about a specific Banano account.                   |
| `banano-block-info`          | Displays information about a specific Banano block.                           | Alias for viewing information about a specific Banano block.                     |
| `banano-block-count`         | Displays the total number of blocks in the Banano blockchain.                 | Alias for counting the total number of blocks in the Banano blockchain.          |
| `banano-work-generate`       | Generates proof of work for a Banano block.                                   | Alias for generating proof of work for a Banano block.                           |
| `banano-monitor`             | Starts the Banano node monitor to monitor the node's status.                  | Alias for starting the Banano node monitor.                                      |
| `banano-process`             | Processes pending transactions in the Banano wallet

.                          | Alias for processing pending transactions in the Banano wallet.                  |
| `banano-broadcast`           | Broadcasts pending transactions in the Banano wallet.                         | Alias for broadcasting pending transactions in the Banano wallet.                |
| `banano-account-create`      | Creates a new Banano account in the Banano wallet.                            | Alias for creating a new Banano account in the Banano wallet.                    |
| `banano-account-remove`      | Removes a Banano account from the Banano wallet.                              | Alias for removing a Banano account from the Banano wallet.                      |
| `banano-account-move`        | Moves Banano funds between accounts in the Banano wallet.                     | Alias for moving Banano funds between accounts in the Banano wallet.             |
| `banano-account-rename`      | Renames a Banano account in the Banano wallet.                                | Alias for renaming a Banano account in the Banano wallet.                        |
| `banano-account-history`     | Displays the transaction history for a specific Banano account.               | Alias for viewing the transaction history of a specific Banano account.          |
| `banano-account-key`         | Displays the public key of a specific Banano account.                         | Alias for viewing the public key of a specific Banano account.                   |
| `banano-receive-minimum`     | Displays the minimum amount required to receive in the Banano wallet.         | Alias for checking the minimum receive amount in the Banano wallet.              |
| `banano-proof-of-work-validate` | Validates the proof of work for a specific Banano block.                   | Alias for validating the proof of work of a specific Banano block.                |
| `banano-display-seed`        | Displays the seed of the Banano wallet.                                       | Alias for displaying the seed of the Banano wallet.                              |
| `banano-generate-seed`       | Generates a new seed for the Banano wallet.                                   | Alias for generating a new seed for the Banano wallet.                           |
| `banano-export-seed`         | Exports the seed of the Banano wallet.                                        | Alias for exporting the seed of the Banano wallet.                               |
| `banano-import-seed`         | Imports a seed to the Banano wallet.                                          | Alias for importing a seed to the Banano wallet.                                 |
| `banano-change-seed`         | Changes the seed of the Banano wallet.                                        | Alias for changing the seed of the Banano wallet.                                |
| `banano-validate-seed`       | Validates the seed of the Banano wallet.                                      | Alias for validating the seed of the Banano wallet.                              |

These aliases provide convenient shortcuts for executing various Banano node and wallet commands.

## Recommended Hardware
For optimal performance when running a Banano node, consider the following hardware recommendations:

- **Processor**: Choose a modern multicore processor with a clock speed of at least 2.5 GHz to enable efficient concurrent processing. For voting nodes and principal nodes, consider having at least 4 CPU cores.

- **RAM**: Allocate a minimum of 4 GB of RAM, although more is preferable, depending on network load and transaction volume to handle the increased workload efficiently. 

- **Storage**: 50 GB of storage space available or more, as the Banano blockchain will grow over time. Consider using SSD or NVMe-based storage for faster access and improved performance.

- **Network Connection**: Ensure a stable and reliable internet connection with sufficient bandwidth to handle incoming and outgoing network traffic effectively.

- **VPS or Dedicated Server**: It is also advisable to utilize a datacenter environment, particularly SSD VPS providers like Contabo, Hetzner, Vultr, OVH, and DigitalOcean, for optimal performance. Running a Banano node can consume significant computational resources, especially during synchronization and transaction processing. Therefore, it is recommended to allocate dedicated hardware resources specifically for running the node to ensure optimal performance and reliability.

## Self-configurable Installation

Please check the [wiki](https://github.com/amamel/banano-node-docker/wiki) for more detailed instructions on how to manually self-configure Banano Node Docker.

## Credits

* [JrCs/docker-letsencrypt-nginx-proxy-companion](https://github.com/JrCs/docker-letsencrypt-nginx-proxy-companion)
* [jwilder/nginx-proxy](https://github.com/jwilder/nginx-proxy)
* [lephleg/nano-node-docker](https://github.com/lephleg/nano-node-docker)
* [Moonano Fast Sync RocksDB Ledger](https://moonano.net/ledger/)
* [Nanocurrency](https://github.com/nanocurrency/nano-node)
* [Nano Node Monitor](https://github.com/NanoTools/nanoNodeMonitor)
* [v2tec/watchtower](https://github.com/v2tec/watchtower)
* [Very Cute Cat Fast Sync LMBD Ledger](https://lmdb.cutecat.party/)


## License
This script is released under the [MIT License](https://opensource.org/licenses/MIT).

## Support
If you encounter any issues or have suggestions for improvements, we encourage you to utilize the "Issues" tab on our GitHub repository. Your feedback is valuable in making this project better. We also welcome discussions about new features, container types, or on script improvements and suggestions. For quicker feedback, join the [Banano Discord server](https://chat.banano.cc/) and navigating to the #frankensteins-lab Banano development channel. It's a great place to engage in conversations, offer suggestions, and receive support from other Banano developers.

I'd like to express my gratitude to the developers behind the other tools in this project. If you find those tools useful, please consider donating to or contributing to their projects. Your contributions, whether it's reporting bugs or creating Pull Requests, are incredibly helpful.

If you find this tool helpful and valuable, I kindly ask you to show your support by giving this project a star ⭐️. Your support will help Banano reach more people and make a positive impact. Thank you, and cheers!
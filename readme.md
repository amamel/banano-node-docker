# Banano Node Docker

<div align="center">
    <img src="banano-node-docker.png" alt="Banano Node Docker Logo" width='300px' height='auto'/>
</div>

The Banano Node Docker Bash script automates the setup process for running a Banano node using Docker. It pulls the necessary Docker images, sets up the required configuration, and initializes the Banano node. This makes the process of setting up and configuring a Banano node more efficient and secure.

## Prerequisites

To ensure that the script runs smoothly, please make sure you have Docker and Docker Compose installed on your system. If either of these dependencies is missing, the script will attempt to install them automatically for you.

## Usage

To download or clone the latest release and run the script, follow the instructions below:

Quick launch:
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
If you plan to use SSL with your Banano node, it is important to update the `docker-compose.letsencrypt.yml` file with your domain name and email. This step is necessary to configure SSL certificates correctly for your domain.

### Options

| Option    | Description                                                            |
|-----------|------------------------------------------------------------------------|
| `-s`      | Display the seed for the generated wallet.                              |
| `-d <domain>` | Specify a domain name for the Banano node. Enables SSL using Let's Encrypt. |
| `-e <email>`  | Specify an email address for Let's Encrypt SSL certificate notifications.  |
| `-q`      | Run the script in quiet mode, suppressing most of the output.           |
| `-f`      | Enable fast-syncing by downloading the latest ledger files.             |


## Functionality

When the script is executed, it performs a series of functions, which are outlined below:

- Verifies if the script is running on a supported operating system. If not supported, it displays an error message and exits.
- Ensures that all necessary tools are installed to run the script.
- Retrieves and applies the latest Docker image tag for the Banano Node.
- Enables the fast synchronization mode for the Banano Node.
- Verifies if the initial setup for the Banano Node has been completed.
- Starts the Docker stack for running the Banano Node.
- Configures and starts the necessary Docker containers for the Banano Node.
- Waits for the Banano Node to initialize and become ready.
- Sets the alias for the Banano Node.
- Checks if a wallet is already generated and generates a new wallet if needed.
- Configures the Banano node monitor for monitoring the node's status.

## Requirements
For optimal performance when running a Banano node, consider the following hardware recommendations:

**OS:**
- Ubuntu 20.04/Debian 

**Minimum Hardware:**

| Hardware            | Recommendation                                                  |
|---------------------|-----------------------------------------------------------------|
| Processor           | 2 CPU 2.5GHz                                                    |
|                     | 4 CPU for Voting/Principal Nodes                                |
| RAM                 | 4 GB+ depending on network load and transaction volume         |
| Storage             | 50GB SSD/NVMe (Current Ledger ~25GB LMDB)                       |
| Network Connection  | 1TB Bandwidth, 24/7 Connectivity                                |

## Additional Notes

- The script supports easy SSL setup using Let's Encrypt if a domain name is provided.
- To expedite the synchronization process, you can enable fast-syncing by using the `-f` option. This allows you to download the latest ledger files for quicker synchronization. **This is still experimental**.
- The script automatically updates the Banano Node Monitor configuration file, including essential information such as the node's RPC IP, account address, node name, and other relevant settings.

## Talk to the Banano node Command Line Interface (CLI)

To execute commands from the Banano node's Command Line Interface (CLI), you have two options:

**Option 1: Enter the Banano node container and execute commands directly:**
```
docker exec -it banano-node /usr/bin/bananode <command>
```

**Option 2: Use the shorthand alias provided by the installer for executing Banano node and wallet commands:**
```
benis <command>
```

These options provide convenient ways to execute Banano node and wallet commands, giving you flexibility in accessing the Banano node's CLI.

Apologies for the confusion. Here is the updated markdown table with only the aliases and their descriptions:

| Alias | Description |
| --- | --- |
| `Benis` | Banano Node CLI: Formal, respectful, capital B |
| `benis` | Banano Node CLI: CLI b, ok |
| `banano-node` | Banano Node CLI: Banano Node |
| `banano-rpc` | Banano Node CLI: Banano RPC |
| `banano-wallet` | Banano Node CLI: Banano Wallet |
| `banano-status` | Banano Node CLI: Banano Node Status |
| `banano-restart` | Banano Node CLI: Restart Banano Node |
| `banano-update` | Banano Node CLI: Update Banano Node |
| `banano-logs` | Banano Node CLI: View Banano Node Logs |
| `banano-account-create` | Create a Banano account |
| `banano-account-list` | List Banano accounts |
| `banano-account-remove` | Remove a Banano account |
| `banano-account-rename` | Rename a Banano account |
| `banano-account-history` | Get account history |
| `banano-account-info` | Get account information |
| `banano-account-move` | Move an account |
| `banano-account-key` | Get the account's public key |
| `banano-account-get` | Get the account for a given public key |
| `banano-account-forks` | Get account forks |
| `banano-account-balance-total` | Get the total account balance |
| `banano-account-representative` | Get the account representative |
| `banano-account-weight` | Get the account weight |
| `banano-account-weights` | Get the account weights |
| `banano-account-confirmations` | Get the account confirmations |
| `banano-account-create-work` | Create work for an account |
| `banano-balance` | Get the wallet balance |
| `banano-accounts` | List wallet accounts |
| `banano-send` | Send Banano from the wallet |
| `banano-import` | Import a Banano wallet |
| `banano-export` | Export a Banano wallet |
| `banano-history` | Get wallet transaction history |
| `banano-receive` | Receive Banano in the wallet |
| `banano-representatives` | List wallet representatives |
| `banano-delegators` | List wallet delegators |
| `banano-account-info` | Get account information from the wallet |
| `banano-block-info` | Get block information from the wallet |
| `banano-block-count` | Get the block count from the wallet |
| `banano-work-generate` | Generate work using the wallet |


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
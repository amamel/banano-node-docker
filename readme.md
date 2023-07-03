# Banano Node Docker

<div align="center">
    <img src="banano-node-docker.png" alt="Banano Node Docker Logo" width='300px' height='auto'/>
</div>

The Banano Node Docker Bash script automates the setup process for running a Banano node using Docker. It pulls the necessary Docker images, sets up the required configuration, and initializes the Banano node. This makes the process of setting up and configuring a Banano node more efficient and secure.

## Prerequisites

Docker and Docker Compose are required, if either of these are missing, the script will attempt to install them automatically for you.

## Usage

To download or clone the latest release, open a bash terminal and launch the installation script:

## ❯ Quick Install

```bash
curl -sL "https://raw.github.com/amamel/banano-node-docker/master/install.sh" | sh
```
Note: If using SSL, read more about SSL / HTTPS with Let's Encrypt before running installer below.



## ❯ Manual Install




| Option    | Description                                                            |
|-----------|------------------------------------------------------------------------|
| `-s`      | Display the seed for the generated wallet.                              |
| `-d <domain>` | Specify a domain name for the Banano node. Enables SSL using Let's Encrypt. |
| `-e <email>`  | Specify an email address for Let's Encrypt SSL certificate notifications.  |
| `-q`      | Run the script in quiet mode, suppressing most of the output.           |
| `-f`      | Enable fast-syncing by downloading the latest ledger files.             |

```
cd ~
git clone https://github.com/amamel/banano-node-docker.git
cd ~/banano-node-docker
sudo ./banano.sh -d yourdomain.com -e youremail@yourdomain.com -s
```

If a domain name is available for your host, Banano Node Docker can also serve your node monitor securely using HTTPS. This feature is enabled (using the `-d` argument with the installer), the stack will also include the following containers:

| Container name        | Description                                                                                               |
|-----------------------|-----------------------------------------------------------------------------------------------------------|
| nginx-proxy           | An instance of the popular Nginx web server running in a reverse proxy setup. Serves as a gateway to the host. |
| nginx-proxy-letsencrypt | A lightweight companion container for the nginx-proxy. Enables automatic creation/renewal of Let's Encrypt certificates. |

#### SSL / HTTPS with Let's Encrypt

To set up SSL for your Banano node, update the `docker-compose.letsencrypt.yml` file with your domain name and email address. This ensures the SSL certificates are configured correctly for your domain. If you use Cloudflare, clear the cache in Cloudflare and your browser. Also, update your Cloudflare account to reflect the new SSL certificates.

Let's Encrypt has rate limits to prevent abuse on the number of certificates issued for a specific set of domains within a certain time period. If you've reached the rate limit for your domain, you'll need to wait until it is lifted or consider using a different domain for your node.



### Install with fast-syncing

Banano Node Docker stack can also bootstrap any newly created node (or an existing one) with the latest ledger files using either LMDB or RocksDB. This implies that you are willing to trust third-party sources for your node history. The latest ledger files are obtained from the Banano community: [cutecat](https://lmdb.cutecat.party/) and [moonano](https://moonano.net/ledger/), while the script handles the extraction and file placement.

Just add the `-f` flag to your installer command:

```
sudo ./banano.sh -t V25.1 -f
```

**This feature is experimental and may result in loss of data. You are strongly adviced to BACKUP your wallet seed before trying to fast-sync an existing node.**

## Requirements

For optimal performance when running a Banano node, consider the following hardware recommendations:

**OS:**

- Ubuntu 20.04

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
- To expedite the synchronization process, you can enable fast-syncing by using the `-f` option. This allows you to download the latest ledger files for quicker synchronization.
- The script automatically updates the Banano Node Monitor configuration file, including essential information such as the node's RPC IP, account address, node name, and other relevant settings.

## Talk to the Banano node Command Line Interface (CLI)

Banano node runs inside the banano-node container. In order to execute commands from its [Command Line Interface](https://docs.nano.org/commands/command-line-interface/) you'll have to enter the container or execute them from the Banano node's Command Line Interface (CLI), you have two options:

**Option 1: Enter the Banano node container and execute commands directly:**

```
docker exec -it banano-node /usr/bin/bananode <command>
```

**Option 2: Use the shorthand alias provided by the installer for executing Banano node and wallet commands:**

```
benis <command>
```

These options provide convenient ways to execute Banano node and wallet commands, giving you flexibility in accessing the Banano node's CLI.

| Alias | Description |
| --- | --- |
| `benis` | Banano Node CLI: Shorthand access to Banano Node CLI. Benis. (CLI benis, ok) |
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

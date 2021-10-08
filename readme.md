# Banano Node Docker

<div align="center">
    <img src="banano-node-docker.png" alt="Banano Node Docker Logo" width='300px' height='auto'/>
</div>

## **Description**

**Install a Banano node on your server with a vast variety of tools in a couple of minutes!** 💫

<table>
	<tr>
        <th>Notice</th>
    </tr>
    	<tr>
        <td>
        Banano Node Docker is an automated installer intented to be used for development purposes. Main network nodes with significant delegated amounts should not be left unattended to upgrade automatically and require special monitoring and security measures.
        </td>
    </tr>
</table>

<!--<table>
	<tr>
        <th>Note</th>
    </tr>
    	<tr>
        <td>
        For hosting a Banano node in the <a href="https://beta.nano.org/" target="_blank">BETA network</a>, checkout the "<a href="https://github.com/lephleg/nano-node-docker/tree/beta"><b>beta</b></a>" branch.
        </td>
    </tr>
</table>-->

This project will build and deploy the following containers on your Docker host:


<table>
	<tr>
		<th width="200px">Container name</th>
		<th>Description</th>
 	</tr>
 	<tr>
   <td><b>banano-node</b></td>
   		<td>The Banano node created out of the official <a href="https://hub.docker.com/r/bananocoin/banano" target="_blank">Banano Docker Image</a>. RPC is enabled but <u>not</u> publicly exposed.</td>
 	</tr>
	<tr>
  		<td><b>banano-node-monitor</b></td>
   		<td>The popular Banano Node Monitor PHP application based on <a href="https://hub.docker.com/r/nanotools/nanonodemonitor/" target="_blank">NanoTools's Docker image</a>.</td>
 	</tr>
	<tr>
  		<td><b>watchtower</b></td>
   		<td>A process watching all the other containers and automatically applying any updates to their base image. No need to manually upgrade your node anymore.</td>
 	</tr>
</table>

### **SSL Support with Let's Encrypt**

Optionally, if a domain name is available for your host, Banano Node Docker can also serve your monitor securely using HTTPS. If this feature is enabled (using the `-d` argument with the installer), the stack will also include the following containers:

<table>
	<tr>
		<th width="220px">Container name</th>
		<th>Description</th>
 	</tr>
 	<tr>
   <td><b>nginx-proxy</b></td>
   		<td>An instance of the popular Nginx web server running in a reverse proxy setup. Handles the traffic and serves as a gateway to your host.</td>
 	</tr>
	<tr>
  		<td><b>nginx-proxy-letsencrypt</b></td>
   		<td>A lightweight companion container for the nginx-proxy. It allows the creation/renewal of Let's Encrypt certificates automatically.</td>
 	</tr>
</table>

## ** Recommended Hardware **
- Run the node in a datacenter. Most SSD VPS packages will work. (Contabo, Hetzner, Vultr, OVH, DigitalOcean, etc.)
- 1 modern CPU core minimum. 2 or more is recommended especially for voting nodes and principal nodes.
- 50GB SSD free disk space (database is ~10GB in size at the moment) (NVMe recommended) 
- 2 GB system RAM or more. 4 GB or more is recommended especially for voting nodes and principal nodes

## ** Installing Dependencies Ubuntu 16.04, 18.04, and 20.04, Debian 8, 9, 10, and 11**

```
sudo apt update;
sudo apt upgrade -y;
sudo apt-get install -y git cmake make g++ curl wget python-dev;
apt install python3-pip;
pip install cmake-format;
```

## **Quick Start**

Download or clone the latest release, open a bash terminal and fire up the installation script:

```
$ cd ~ && git clone https://github.com/amamel/banano-node-docker.git && cd ~/banano-node-docker
$ sudo ./banano.sh -s
```

**That's it!** You can now navigate to your host IP to check your Banano Node Monitor dashboard. **Do not forget to write down** your wallet seed as it appears in the output of the installer.


## **Quick Start with SSL and Fast Sync**

```
$ cd ~ && git clone https://github.com/amamel/banano-node-docker.git && cd ~/banano-node-docker
$ sudo ./banano.sh -f -s -t V22 -d domain.com -e email@email.com
```

### Available command flags/arguments

The following flags are available when running the stack installer:

<table>
    <tr>
        <th width="20px">Flag</th>
        <th width="180px">Argument</th>
        <th>Description</th>
    </tr>
    <tr>
        <td><b>-d</b></td>
        <td>your domain name</td>
        <td>Sets the domain name to be used. Required for SSL-enabled setups.</td>
    </tr>
    <tr>
        <td><b>-e</b></td>
        <td>your email address</td>
        <td>Sets your email for Let's Encrypt certificate notifications. Optional for SSL-enabled setups.</td>
    </tr>
    <tr>
        <td><b>-f</b></td>
        <td>-</td>
        <td>Enables fast-syncing by fetching the latest ledger and placing it into <i>/root/Banano/</i> inside <b>banano-node</b>
            container.</td>
    </tr>
    <tr>
        <td><b>-q</b></td>
        <td>-</td>
        <td>Quiet mode. Hides any output.</td>
    </tr>
    <tr>
        <td><b>-s</b></td>
        <td>-</td>
        <td>Prints the unecrypted seed of the node wallet during the setup (<b>WARNING:</b> in most cases you may want to avoid this
            for security purposes).</td>
    </tr>
    <tr>
        <td><b>-t</b></td>
        <td>Docker image tag</td>
        <td>Indicates the preferred tag for the Banano Docker image. Defaults to "latest". Optional.</td>
    </tr>
</table>

### Banano Node CLI bash alias

Banano node runs inside the banano-node container. In order to execute commands from its [Command Line Interface](https://docs.nano.org/commands/command-line-interface/) you'll have to enter the container or execute them by using the following Docker command:

```
$ docker exec -it banano-node banano_node <command>
```

For convinience the following shorthand alias is set by the installer:

```
$ banano-node <command>
```

Both of the above formats are interchangeable.

## Examples

### **Install with SSL enabled**

After your DNS records are setup, fire up the installation script with the domain (-d) argument:

```
$ sudo ./banano.sh -d mydomain.com -e myemail@example.com
```

The email (-e) argument is optional and would used by Let's Encrypt to warn you of impeding certificate expiration.

**Done!** Navigate to your domain name to check your Banano Node Monitor Dashboard over HTTPS!

### Install with fast-syncing

Banano Node Docker stack can also bootstrap any newly created node (or an existing one) with the latest ledger files. This implies that you are willing to trust third-party sources for your node history. The latest ledger files are obtained from [Steam Powered Taco](https://banano.steampoweredtaco.com/).

Just add the `-f` flag to your installer command:

```
$ sudo ./banano.sh -f
```
**WARNING: You are strongly advised to BACKUP your wallet seed before trying to fast-sync an existing node.**

### **Install with a different Banano node image**

Want to install a specific Banano node image for testing? Add a tag -t and you can easily specify a specific Banano node version:

```
$ sudo ./banano.sh -t V22
```

### **Combining installer flags**

All the installer flags can be chained, so you can easily combine them like this:

```
$ sudo ./banano.sh -sfd mydomain.com -e myemail@example.com
```

(_display seed, apply fast-sync and use Let's Encrypt with your email supplied_)
<div align="center">
    <img src="screenshot.png" alt="Banano Node Docker Screenshot" width='1000px' height='auto'/>
</div>

## Self-configurable Installation

Please check the [wiki](https://github.com/amamel/banano-node-docker/wiki)
 for more detailed instructions on how to manually self-configure Banano Node Docker.

 ## **Contributions**
 Please use the issues tab to report issues.

## **Credits**

* **[lephleg/nano-node-docker](https://github.com/lephleg/nano-node-docker)**
* **[Nanocurrency](https://github.com/nanocurrency/nano-node)**
* **[Banano Node Monitor](https://github.com/NanoTools/nanoNodeMonitor)**
* **[jwilder/nginx-proxy](https://github.com/jwilder/nginx-proxy)**
* **[JrCs/docker-letsencrypt-nginx-proxy-companion](https://github.com/JrCs/docker-letsencrypt-nginx-proxy-companion)**
* **[v2tec/watchtower](https://github.com/v2tec/watchtower)**
* **[Banano Ledger](https://banano.steampoweredtaco.com/)**

## **Support**

## **Need help? Have a feature suggestion? Discovered a bug?**
Join the Banano [Discord](https://chat.banano.cc/) server and head over to #frankensteins-lab if you want to comment on features, suggest new container types, or ask the Banano community for help.

If you use some of the other tools in this project, please consider donating or contributing on their projects. Reporting bugs and creating Pull Requests helps.

If you like this tool, **please give this project a star** ⭐️ so more people get to know it. Cheers! :)

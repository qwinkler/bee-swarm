# Bee Swarm Node
 
These utils are created to insatall and operate with [Bee Swarm](https://docs.ethswarm.org/docs)

## Getting started with Hetzner Cloud

- Create a new node: CX21 (2 CPU / 4 RAM);
- Create a new volume for 45 GB (may be easily resized later);

Login to the node:  
```console
root@bee-node:~$ df -h | grep "/dev/sdb"
/dev/sdb         45G   31G   12G  72% /mnt/blah-blah
root@bee-node:~$ umount /mnt/blah-blah
root@bee-node:~$ mkdir -p /mnt/bee
root@bee-node:~$ mount /dev/sdb /mnt/bee
root@bee-node:~$ # optional step
root@bee-node:~$ rm -rf /mnt/blah-blah
```

Download the installation script and run it:  
```bash
curl -s -o install.sh https://raw.githubusercontent.com/qwinkler/bee-swarm/main/install.sh \
  && chmod +x install.sh
./install.sh
```

Run a message in the [discord channel](https://discord.com/channels/799027393297514537/813744618776428594):  
```
sprinkle 0x0000000000000000000000000000000000000000
```

And/or use these cranes:  
- [GOERLI FAUCET](https://faucet.ethswarm.org)
- [Goerli Authenticated Faucet](https://faucet.goerli.mudit.blog)

Get the gbzz tokens ([instruction](https://telegra.ph/gbzz-geth-02-22))

And reload the service:
```bash
root@bee-node:~$ ./local-dash.sh
...
Please enter your choice:5
```

## Backup and export keys

Download the export script and run it:  
```bash
curl -s -o export.sh https://raw.githubusercontent.com/qwinkler/bee-swarm/main/exportSwarmKey.sh \
  && chmod +x export.sh
./export.sh
```

Execute these commands from localhost:
```bash
cd /path/to/backup/folder
scp_insecure -r root@127.0.0.1:/mnt/bee/data/statestore/ .
scp_insecure -r root@127.0.0.1:/mnt/bee/data/keys .
scp_insecure -r root@127.0.0.1:/root/key.json .
```

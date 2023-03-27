### Install dependencies, if needed
```
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl build-essential git wget jq make gcc tmux chrony lz4 unzip
```

### Install Go
```
ver="1.19.3"
cd $HOME
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
source ~/.bash_profile
go version
```

### Download and build binaries
```
cd $HOME 
rm -rf celestia-node 
git clone https://github.com/celestiaorg/celestia-node.git 
cd celestia-node/ 
git checkout tags/v0.7.2
make build 
make install 
make cel-key 
```

### Create new wallet or restore ur wallet 
```
cd ~/celestia-node
echo "export CEL_WALLET=YOUR-WALLET-NAME" >> $HOME/.bash_profile
echo "export CEL_CHAINNAME=blockspacerace" >> $HOME/.bash_profile
echo "export CEL_NODETYPE=light" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Create new wallet (Remember to write down seed phrases)
./cel-key add $CEL_WALLET --keyring-backend test --node.type $CEL_NODETYPE --p2p.network $CEL_CHAINNAME

# Recover ur wallet with your seed phrase (optional)
./cel-key add $CEL_WALLET --keyring-backend test --node.type $CEL_NODETYPE --p2p.network $CEL_CHAINNAME --recover

# List created wallet
./cel-key list --node.type $CEL_NODETYPE --keyring-backend test --p2p.network $CEL_CHAINNAME

# Save wallet address 
echo "export CEL_WALLET_ADDR=$(./cel-key show $CEL_WALLET -a --node.type $CEL_NODETYPE --keyring-backend test --p2p.network $CEL_CHAINNAME | grep -e "^celestia")" >> $HOME/.bash_profile
source $HOME/.bash_profile
echo $CEL_WALLET_ADDR

# Initialize pre-configuration of your node
celestia $CEL_NODETYPE init --p2p.network $CEL_CHAINNAME

# Enable gateway
sed -i.bak -e "s/Enabled = .*/Enabled = true/" $HOME/.celestia-light-blockspacerace-0/config.toml
```

### Create service
```
sudo tee /etc/systemd/system/celestia-light.service > /dev/null <<EOF
[Unit]
Description=celestia light
After=network-online.target

[Service]
User=$USER
ExecStart=$(which celestia) light start --core.ip https://rpc-blockspacerace.pops.one --gateway --gateway.addr 0.0.0.0 --gateway.port 26659 --keyring.accname ${CEL_WALLET} --p2p.network ${CEL_CHAINNAME} --metrics.tls=false --metrics --metrics.endpoint otel.celestia.tools:4318
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
```

### Start Celestia DA light node
```
sudo systemctl daemon-reload
sudo systemctl enable celestia-light
sudo systemctl restart celestia-light
```

### Check logs
```
sudo journalctl -u celestia-light -f -o cat
```

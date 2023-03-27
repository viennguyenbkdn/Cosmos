### Set your moniker name
```
NODENAME="YOUR_NODE_MONIKER"
```

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
rm -rf celestia-app
git clone https://github.com/celestiaorg/celestia-app.git
cd celestia-app
# APP_VERSION=$(curl -s https://api.github.com/repos/celestiaorg/celestia-app/releases/latest | jq -r ".tag_name")
# git checkout tags/$APP_VERSION -b $APP_VERSION
git checkout v0.12.1
make install
```

### Create service
```
sudo tee /etc/systemd/system/celestia-appd.service > /dev/null <<EOF
[Unit]
Description=celestia
After=network-online.target

[Service]
User=$USER
ExecStart=$(which celestia-appd) start --home $HOME/.celestia-app
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable celestia-appd
```

### Config app
```
CELESTIA_PORT=20
echo "export CELESTIA_CHAIN_ID=blockspacerace-0" >> $HOME/.bash_profile
echo "export CELESTIA_PORT=${CELESTIA_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

celestia-appd config chain-id $CELESTIA_CHAIN_ID
celestia-appd config keyring-backend test
celestia-appd config node tcp://localhost:${CELESTIA_PORT}657
celestia-appd init $NODENAME --chain-id $CELESTIA_CHAIN_ID
```

### Download Genesis 
```
wget -qO $HOME/.celestia-app/config/genesis.json https://raw.githubusercontent.com/celestiaorg/networks/master/blockspacerace/genesis.json
```

### Set seeds and peers
```
SEEDS=""
PEERS="be935b5942fd13c739983a53416006c83837a4d2@178.170.47.171:26656,cea09c9ac235a143d4b6a9d1ba5df6902b2bc2bd@95.214.54.28:20656,5c9cfba00df2aaa9f9fe26952e4bf912e3f1e8ee@195.3.221.5:26656,7b2f4cb70f04f2e9befb6ace66ce1ac7b3bea5b4@178.239.197.179:26656,7ee2ba21197d58679cfc1517b5bbc6465bed387a@65.109.67.25:26656,dc0656ab58280d641c8d10311d86627255bec8a1@148.251.85.27:26656,ccbd6262d0324e2e858594b639f4296cc4952c93@13.57.127.89:26656,a507b2bda6d2974c84ae1e8a8b788fc9e44d01f7@142.132.131.184:26656,9768290c60a746ee97ef1a5bcb8bee69066475e8@65.109.80.150:2600"

sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.celestia-app/config/config.toml
```

### Config pruning, set minimum gas price, enable prometheus and reset chain data
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.celestia-app/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.celestia-app/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.celestia-app/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.celestia-app/config/app.toml

sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0utia\"/" $HOME/.celestia-app/config/app.toml
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.celestia-app/config/config.toml
```

### Set custom ports
```
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://0.0.0.0:${CELESTIA_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://0.0.0.0:${CELESTIA_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${CELESTIA_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${CELESTIA_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${CELESTIA_PORT}660\"%" $HOME/.celestia-app/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${CELESTIA_PORT}317\"%; s%^address = \":8080\"%address = \":${CELESTIA_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${CELESTIA_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${CELESTIA_PORT}091\"%" $HOME/.celestia-app/config/app.toml
```

### Download Snapshot
```
curl -L https://onepiece-cosmos-explorer.xyz/snapshot/celestia/blockspacerace-0_latest.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.celestia-app
```

### Start service
```
sudo systemctl restart celestia-appd
```

### Check logs
```
sudo journalctl -u celestia-appd -f -o cat
```

### Create wallet then write down ur seedphrase
- Create wallet 
```
celestia-appd keys add $CELESTIA_WALLET --keyring-backend test
```
- Go to discord of Celestia to get faucet: [Celestia discord](https://discord.gg/celestiacommunity)

### Check synchronization status and make sure ur node get fully sync
```
celestia-appd status 2>&1 | jq .SyncInfo
```

### Create validator 
```
celestia-appd tx staking create-validator \
--amount=1000000utia \
--pubkey=$(celestia-appd tendermint show-validator) \
--moniker="YOUR_MONIKER_NAME" \
--identity="YOUR_KEYBASE_ID" \
--website="YOUR_WEBSITE_URL"
--chain-id=$CELESTIA_CHAIN_ID \
--commission-rate=0.10 \
--commission-max-rate=0.20 \
--commission-max-change-rate=0.01 \
--min-self-delegation=1 \
--from= $CELESTIA_WALLET
--gas-prices=0.1utia \
--gas-adjustment=1.5 \
--gas=auto \
--fees=5000utia \
-y
```

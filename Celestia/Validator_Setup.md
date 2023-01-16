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
git checkout v0.11.0
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
echo "export CELESTIA_CHAIN_ID=mocha" >> $HOME/.bash_profile
echo "export CELESTIA_PORT=${CELESTIA_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

celestia-appd config chain-id $CELESTIA_CHAIN_ID
celestia-appd config keyring-backend test
celestia-appd config node tcp://localhost:${CELESTIA_PORT}657
celestia-appd init $NODENAME --chain-id $CELESTIA_CHAIN_ID
```

### Download Genesis 
```
wget -qO $HOME/.celestia-app/config/genesis.json https://onepiece-cosmos-explorer.xyz/snapshot/celestia/genesis.json
```

### Set seeds and peers
```
SEEDS=""
PEERS="673c7bb277bd020a7a8a669985e93472e674ce1e@75.119.130.31:26656,71f1276711418afa9d1b3893d442c3b220732843@146.0.40.146:26656,4988ce8f852eff790e2989bdc1e0f3edf3baac0e@173.212.242.175:20656,cc8bc8ace772faf69071b6673bd4293555f1d84b@65.21.128.125:26656,44284143b83e2a15bad55838f88de205a26c273e@159.65.16.143:26656,10b17f4cb59622628eaecc533d9f736fb6d852ca@149.102.136.70:36656,55dbbe3ddb0d488a4c9355a1a69c67dc58c15985@38.242.150.143:26656,6b87c9ed230eb6fc0317ec314105e795578ae75f@45.94.209.94:26656,eeb70fc0e8a339d7f636d39f7621d307a213e422@85.239.235.146:26656,92c81a3973497205d8fa7642f07947f67b3cb061@51.159.142.106:26656,721aec46e29fb4d68144e998ebcb7cb25e6e1ba6@185.144.99.245:26656,3fdae945ec5dde52b0a99c069cbfe595fa685b6a@185.237.253.220:26656,314e2b38b0f1a1848f0b9a10b1a7759cf2342224@38.242.133.24:26656,94b63fddfc78230f51aeb7ac34b9fb86bd042a77@46.4.53.94:30549,4826d6b479b7af833347538ebf2ed1b040817adb@207.180.223.220:26656,a7a5295de04c8033f0de309cfb1f4b3512cd3db2@75.119.138.205:26656,9fdb738464fda931c70f5be1c624d933e009ec66@103.50.32.25:26656,f7212271573a3a61a1b79174979231d45ce96a4f@164.68.113.198:20656,a687e6c9a13ee52f9f8b94121fa2550b5cd19625@65.109.106.91:19656,6517861b641f4d015cb0b7a4c2a9bb06744853d6@154.26.157.144:26656,5eb27ead4be5bce8b54c6d13477629b30e69e7cf@38.242.150.132:20656,921064a245d73915f680b61bfd5c0d91ff57bcae@75.119.133.133:26656,d00ef425145afbfa91e49602f4f760c3e953575c@65.108.202.230:28656,22a96428431cf90b57d953de4e83953a36f18bae@149.102.133.193:26656,9ef909374bfbb35204871cba64342bef92c8e70c@102.129.138.248:26656,7846b72b6b0750b9095a47a23f8cf4dc765e0599@109.123.243.33:26656,7fc6a0583096eafcb24f79a759768eb7f49eb265@144.126.144.171:26656,1ce3afd0847ec935e44dd1bf2f9625b2cf356952@85.239.234.174:26656,39974b264b65bedd950e2ff0a016bf7d287a417e@143.198.198.20:26656,7911701811336f2c8926b2fb81f8dbe668310c7b@20.163.75.235:11656,3e3b3c6c98a4ae1ca4571cbdc6a1a0f3395f04a8@149.102.142.146:26656,03a045120131622e86e1d0d1955bb0959639a000@45.10.154.218:26661,73735358600694c634acc36cf6b0bb48e59926f9@154.53.40.177:26656,987f50a5b05c012a3f8c614e02e2c54fc5ab2579@65.109.85.221:6050,a63e3e7ff5abda4b9cf339680c0f0e3935eb1f08@81.0.221.85:26656,4b64fc3440b2c46ab64af0c6e8f04fe69fe2af9c@45.10.154.191:26661,da7452d77880df29c21a72c51f3a818bba96438c@185.216.75.93:26656,86dd7cc1460487c11c42d63a88cdb3b10bbcc20a@38.242.133.169:26656,a7c647340ecfce1de2c71cafe108a9767f15083c@194.242.57.98:26661,32a453c249089180cf704144b0e7cda07df2e56d@165.227.44.76:26656,e20223a2df2164b4f0e34ea07e7bbb0cf7c53ebd@65.109.16.236:26656,5cbbc872a494027da3f2857965b1d0bfba66ada5@45.8.133.104:26656,53bf8ee8f96d58f18e318a621fb59cbc24578a57@45.94.209.89:26656,ed6a79045ab154b2f612ec2d32e4042b65f54b62@149.102.155.37:26656,6cbb57ffdb52189df25d1e27cdefefb949d02cb8@45.10.154.42:26661,e6225af335aee92bf8cff1fbeb35d46b07e395fc@102.129.138.126:26656,51263219a6bd860bf2e171573c8d62b51e65d470@185.202.236.20:26656,bb6fe400ec666e57e114e523ff09b7785ca303d5@185.227.135.173:26656,489b9ad36a4d5127cd0c8ba1e3d89a7c5fe3ca41@65.108.230.45:26656,718105c1a17a0a5577796550469584988529a90b@89.117.55.108:26656,b2c4ab0aa5dc99865a62534a5db77dce6c1c0553@89.163.128.183:26656,65f24d3caf8130cb3c75a916fa2bf69884904b83@185.135.137.220:26661,c158ae6c3532c5a8daf43d1a348fd6314bf5cc8f@159.89.101.182:26656,8d7b40bcabf1270e03014274fa8637e582373fd2@171.237.78.230:28656,9ec779614e435d490ba7fc751e69d605138b1be5@162.55.209.117:26656,b13446bba8bab01993c0acc62f9725e119bbb2d0@161.97.142.41:26661,765acd5ea871656357638f07d33f7512ace70b00@185.182.185.41:26656,1d066cc50d2580b0049414c9d854eb71e994abbf@75.119.159.104:26656,8f586ad5b969804e5e6a3b08ed8fe1abc06dfc9b@194.163.175.142:20656,d3be4a7a729bbd24c0484f481e0679d15bf844f1@23.88.53.12:26656,bc9acc98e26f95a9393181004bcecdb12f0abed2@35.227.135.251:26656,2a7054f07d5ce421e432f5ba074fc61f3203f415@95.31.16.222:20656,381744f03f8c055ccb9304e71cb823fd193e8fe8@86.48.0.122:26656,aac98804ab40d2c281d496f2b40dc7a505ce4be0@38.242.243.96:20656,1f243a32a4c741e6838f247350f0aa7655ea264e@173.249.40.87:26656,07d52bfbe06a14914ae11655d91dfe93d4b32359@38.242.216.251:26656,cfe7d9fed66ee95671c78fe4097fb3987fdb814e@91.241.214.162:26656"
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
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${CELESTIA_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${CELESTIA_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${CELESTIA_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${CELESTIA_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${CELESTIA_PORT}660\"%" $HOME/.celestia-app/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${CELESTIA_PORT}317\"%; s%^address = \":8080\"%address = \":${CELESTIA_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${CELESTIA_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${CELESTIA_PORT}091\"%" $HOME/.celestia-app/config/app.toml
```

### Download Snapshot
```
curl -L https://onepiece-cosmos-explorer.xyz/snapshot/celestia/mocha_latest.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.celestia-app
```

### Start service
```
sudo systemctl start celestia-appd
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
--chain-id=mocha \
--commission-rate=0.10 \
--commission-max-rate=0.20 \
--commission-max-change-rate=0.01 \
--min-self-delegation=1 \
--from= $WALLET
--gas-prices=0.1utia \
--gas-adjustment=1.5 \
--gas=auto \
--fees=5000utia \
-y
```

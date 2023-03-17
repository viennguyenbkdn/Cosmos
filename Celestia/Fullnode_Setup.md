
### Install cac goi can thiet ###
sudo apt update && sudo apt upgrade -y
sudo apt install curl git wget htop tmux build-essential jq make gcc -y

cd $HOME
VER="1.19.3"
wget "https://golang.org/dl/go$VER.linux-amd64.tar.gz"
sudo tar -C /usr/local -xzf "go$VER.linux-amd64.tar.gz"
rm -rf  "go$VER.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile
source $HOME/.bash_profile
go version


cd $HOME
rm -rf celestia-node
git clone https://github.com/celestiaorg/celestia-node.git
cd celestia-node/
git checkout tags/v0.6.4
make install
make cel-key

## Recover wallet
cd ~/celestia-node
CEL_WALLET=TEN-VI
CEL_CHAINNAME=TEN-CHAIN

./cel-key add $CEL_WALLET --keyring-backend test --node.type full --p2p.network $CEL_CHAINNAME --recover

./cel-key list --node.type full --keyring-backend test --p2p.network $CEL_CHAINNAME

celestia full init --p2p.network $CEL_CHAINNAME



sudo tee /etc/systemd/system/celestia-full.service > /dev/null <<EOF
[Unit]
Description=celestia full
After=network-online.target

[Service]
User=$USER
ExecStart=$(which celestia) full start --core.ip https://rpc-mocha.pops.one --keyring.accname ${CEL_WALLET}
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

==============================================================================================================

cd ~/celestia-node
CEL_WALLET=TEN-VI
CEL_CHAINNAME=TEN-CHAIN
./cel-key add $CEL_WALLET --keyring-backend test --node.type light --p2p.network $CEL_CHAINNAME --recover


sudo tee /etc/systemd/system/celestia-light.service > /dev/null <<EOF
[Unit]
Description=celestia light
After=network-online.target

[Service]
User=$USER
ExecStart=$(which celestia) light start --core.ip https://rpc-mocha.pops.one --keyring.accname ${CEL_WALLET}
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

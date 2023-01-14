### Here you have to put name of your moniker (validator) that will be visible in explorer
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

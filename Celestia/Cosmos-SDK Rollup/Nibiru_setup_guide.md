## 1. Download Nibiru SDK repo
```
git clone https://github.com/NibiruChain/nibiru.git
cd nibiru
git checkout v0.19.2 # Check latest version by urself
```

## 2. Convert repo of Nibiru chain to be rollup from L1
```
cd /root/nibiru
# Check Cosmos SDK verison using by Nibiru chain
SDK_VERSION=$(cat go.mod | grep "github.com/cosmos/cosmos-sdk " | awk '{print $2}' | awk -F"\." '{print $1"."$2}')
echo $SDK_VERSION

# Check existing released version of Cosmos-SDK rollkit which is consistent to Nibiru Cosmos-SDK 
curl -s https://github.com/rollkit/cosmos-sdk/tags/ | grep -e "/rollkit/cosmos-sdk/releases/tag/" | awk '{print $NF}' | grep class | sed -e "s/>/\|/g;s/</\|/g" | awk -F"|" '{print $2}' | sort -u | grep rollkit | grep $SDK_VERSION

# Select latest SDK version from above step
SDK_ROLLKIT_VER=YOUR_SELECTED_SDK_VERION

# Check Terdenmint verison using by Nibiru chain
TEND_VERSION=$(cat go.mod | grep "github.com/tendermint/tendermint " | awk '{print $2}' | awk -F"\." '{print $1"."$2}')
echo $TEND_VERSION

# Check existing released version of Tendermint Rollkit which is consistent to Nibiru Tendermint
curl -s https://github.com/rollkit/tendermint/tags  | grep "rollkit/tendermint/releases/tag/" | sed -s "s/.*primary\">\(.*\)<\/a.*/\1/g" | sort -u | grep $TEND_VERSION

# Select latest Tendermint version from above step
TEND_ROLLKIT_VER=YOUR_SELECTED_TEND_VERION

# Edit Cosmos-SDK appchain to be Cosmos SDK rollup
go mod edit -replace github.com/cosmos/cosmos-sdk=github.com/rollkit/cosmos-sdk@$SDK_ROLLKIT_VER
# go mod edit -replace github.com/tendermint/tendermint=github.com/celestiaorg/tendermint@$TEND_ROLLKIT_VER
# Currently using Tendermint v0.34.22-0.20221202214355-3605c597500d
go mod edit -replace github.com/tendermint/tendermint=github.com/celestiaorg/tendermint@v0.34.22-0.20221202214355-3605c597500d
go mod tidy
go mod download
make install
```

## 3. Setting Nibiru Rollup local devnet
```
# Setup some variables
VALIDATOR_NAME=Nibiru-1
CHAIN_ID=nibi-local
KEY_NAME=nibi-key-1
KEY_2_NAME=nibi-key-2
CHAINFLAG="--chain-id ${CHAIN_ID}"
TOKEN_AMOUNT="10000000000000000000000000unibi"
STAKING_AMOUNT="1000000000unibi"
DENOM="unibi"

# reset any existing genesis/chain data
nibid tendermint unsafe-reset-all

# initialize the validator with the chain ID you set
nibid init $VALIDATOR_NAME --chain-id $CHAIN_ID

# add keys for key 1 and key 2 to keyring-backend test
nibid keys add $KEY_NAME --keyring-backend test

nibid keys add $KEY_2_NAME --keyring-backend test

sed -i.bak -e "s|\"stake\"|\"$DENOM\"|g" ../.nibid/config/genesis.json

# add these as genesis accounts
nibid add-genesis-account $KEY_NAME $TOKEN_AMOUNT --keyring-backend test
nibid add-genesis-account $KEY_2_NAME $TOKEN_AMOUNT --keyring-backend test

# set the staking amounts in the genesis transaction
nibid gentx $KEY_NAME $STAKING_AMOUNT --chain-id $CHAIN_ID --keyring-backend test

# collect genesis transactions
nibid collect-gentxs
```

## 4. Start rollup chain
### 4.1 Setup Celestia DA light/fullnode (OPTIONAL)
- [Lightnode setup guide](https://docs.celestia.org/nodes/full-storage-node/)
- [Fullnode setup guide](https://docs.celestia.org/nodes/light-node/)

### 4.2 Start chain
```
# Declare DA_URL
# If DA node and Rollup sequencer are on different server
DA_URL="http://YOUR_PUB_IP:26659"

# If DA node and Rollup sequencer are on same server
DA_URL="http://localhost:26659"

# Create a random Namespace ID for your rollup to post blocks to
NAMESPACE_ID=$(echo $RANDOM | md5sum | head -c 16; echo;)
echo $NAMESPACE_ID 

# Query the DA Layer start height, in this case we are querying blockheight from RPC of a consensus fullnode on Celestia-Blockspacerace
# You can check public of Celestia RPC at here: https://docs.celestia.org/nodes/blockspace-race/#rpc-endpoints
DA_BLOCK_HEIGHT=$(curl https://rpc-blockspacerace.pops.one/block | jq -r '.result.block.header.height')
echo $DA_BLOCK_HEIGHT

# start a sequencer of rollkit chain
nibid start --rollkit.aggregator true --rollkit.block_time 2.35s --rollkit.da_block_time 2.35s --rollkit.da_layer celestia --rollkit.da_config='{"base_url":"$DA_URL","timeout":60000000000,"fee":100,"gas_limit":100000}' --rollkit.namespace_id $NAMESPACE_ID  --rollkit.da_start_height $DA_BLOCK_HEIGHT --p2p.laddr "0.0.0.0:26656" --p2p.seed_mode --log_level debug
```

## 5. Result
- Your rollup chain will run and publish block to Celestia DA layer
![image](https://user-images.githubusercontent.com/91453629/230812555-d6e74939-0c03-4615-b9c2-8df3ba589cc7.png)

- More PFB transaction will be submitted from your rollup chain to DA layer via DA node
![image](https://user-images.githubusercontent.com/91453629/230812670-3aff055e-e9bf-482c-b01e-1557cf622966.png)

### Download repo
git clone https://github.com/NibiruChain/nibiru.git
cd nibiru
git checkout v0.19.2

### Edit repo of nibiru to rollkit from L1 
cd /root/nibiru
go mod edit -replace github.com/cosmos/cosmos-sdk=github.com/rollkit/cosmos-sdk@v0.45.10-rollkit-v0.7.2-no-fraud-proofs
go mod edit -replace github.com/tendermint/tendermint=github.com/celestiaorg/tendermint@v0.34.22-0.20221202214355-3605c597500d
go mod tidy
go mod download
make install

### Setting Nibiru Rollkit local devnet

VALIDATOR_NAME=AX101_174
CHAIN_ID=nibi-local
KEY_NAME=nibi-key-1
KEY_2_NAME=nibi-key-2
CHAINFLAG="--chain-id ${CHAIN_ID}"
TOKEN_AMOUNT="10000000000000000000000000unibi"
STAKING_AMOUNT="1000000000unibi"
DENOM="unibi"

# create a random Namespace ID for your rollup to post blocks to
NAMESPACE_ID=$(echo $RANDOM | md5sum | head -c 16; echo;)
echo $NAMESPACE_ID 
# 80bf6daca2fb6fcc

# query the DA Layer start height, in this case we are querying
# our local devnet at port 26657, the RPC. The RPC endpoint is
# to allow users to interact with Celestia's nodes by querying
# the node's state and broadcasting transactions on the Celestia
# network. The default port is 26657.
DA_BLOCK_HEIGHT=$(curl http://65.108.232.174:20657/block | jq -r '.result.block.header.height')
echo $DA_BLOCK_HEIGHT
# 182353

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

# start a sequencer of rollkit chain
# nibid start --rollkit.aggregator true --rollkit.da_layer celestia --rollkit.da_config='{"base_url":"http://localhost:26659","timeout":60000000000,"fee":6000,"gas_limit":6000000}' --rollkit.namespace_id $NAMESPACE_ID --rollkit.da_start_height $DA_BLOCK_HEIGHT
# nibid start --rollkit.aggregator true --rollkit.block_time 2s --rollkit.da_block_time 2s --rollkit.da_layer celestia --rollkit.da_config='{"base_url":"http://localhost:26659","timeout":60000000000,"fee":100,"gas_limit":100000}' --rollkit.namespace_id $NAMESPACE_ID    --rollkit.da_start_height $DA_BLOCK_HEIGHT
nibid start --rollkit.aggregator true --rollkit.block_time 2s --rollkit.da_block_time 2s --rollkit.da_layer celestia --rollkit.da_config='{"base_url":"http://localhost:26659","timeout":60000000000,"fee":100,"gas_limit":100000}' --rollkit.namespace_id $NAMESPACE_ID  --rollkit.da_start_height $DA_BLOCK_HEIGHT --p2p.laddr "0.0.0.0:26656" --p2p.seed_mode --log_level debug


# Start fullnode rollkit on same server
# Configure same namespace id
NAMESPACE_ID=80bf6daca2fb6fcc
DA_BLOCK_HEIGHT=182353

nibid init $VALIDATOR_NAME_2 --chain-id $CHAIN_ID --home /root/.nibid2/
cp .nibid/config/genesis.json .nibid2/config/

# Edit port
vi .nibid2/config/config.toml
vi .nibid2/config/app.toml
vi .nibid2/config/client.toml

# Get ID of sequencer node
SEQ_NODEID=$(nibid status | jq .NodeInfo.id -r)

# Start fullnode
nibid start --home /root/.nibid2 --rollkit.block_time 2s --rollkit.da_block_time 2s --rollkit.da_layer celestia --rollkit.da_config='{"base_url":"http://localhost:26659","timeout":60000000000,"fee":100,"gas_limit":100000}' --rollkit.namespace_id $NAMESPACE_ID  --rollkit.da_start_height $DA_BLOCK_HEIGHT --p2p.seeds "$SEQ_NODEID@127.0.0.1:26656" --log_level debug

# Add wallet also



=====================================================================================================
Stop and restart rollkit
VALIDATOR_NAME=AX101_174
CHAIN_ID=nibi-local
KEY_NAME=nibi-key-1
KEY_2_NAME=nibi-key-2
CHAINFLAG="--chain-id ${CHAIN_ID}"
TOKEN_AMOUNT="10000000000000000000000000unibi"
STAKING_AMOUNT="1000000000unibi"
DENOM="unibi"

# create a random Namespace ID for your rollup to post blocks to
NAMESPACE_ID=$(echo $RANDOM | md5sum | head -c 16; echo;)
echo $NAMESPACE_ID 
# 80bf6daca2fb6fcc

# query the DA Layer start height, in this case we are querying
# our local devnet at port 26657, the RPC. The RPC endpoint is
# to allow users to interact with Celestia's nodes by querying
# the node's state and broadcasting transactions on the Celestia
# network. The default port is 26657.
DA_BLOCK_HEIGHT=$(curl http://65.108.232.174:20657/block | jq -r '.result.block.header.height')
echo $DA_BLOCK_HEIGHT
# 182353

# reset any existing genesis/chain data on sequencer 
nibid tendermint unsafe-reset-all

# reset any existing genesis/chain data on fullnode
nibid tendermint unsafe-reset-all --home $HOME/.nibid2

# Start sequencer 
nibid start --rollkit.aggregator true --rollkit.block_time 2s --rollkit.da_block_time 2s --rollkit.da_layer celestia --rollkit.da_config='{"base_url":"http://localhost:26659","timeout":60000000000,"fee":100,"gas_limit":100000}' --rollkit.namespace_id $NAMESPACE_ID  --rollkit.da_start_height $DA_BLOCK_HEIGHT --p2p.laddr "0.0.0.0:26656" --p2p.seed_mode --log_level debug

# Get ID of sequencer node
SEQ_NODEID=$(nibid status | jq .NodeInfo.id -r)

# Start fullnode
nibid start --home /root/.nibid2 --rollkit.block_time 2s --rollkit.da_block_time 2s --rollkit.da_layer celestia --rollkit.da_config='{"base_url":"http://localhost:26659","timeout":60000000000,"fee":100,"gas_limit":100000}' --rollkit.namespace_id $NAMESPACE_ID  --rollkit.da_start_height $DA_BLOCK_HEIGHT --p2p.seeds "$SEQ_NODEID@127.0.0.1:26656" --log_level debug




============================================================================
root@AX101-FSN174 ~/nibiru # nibid keys add $KEY_NAME --keyring-backend test

- name: nibi-key-1
  type: local
  address: nibi1w5lr3gxrmtte2c7vusxcve6y0kxmqmxrysl80r
  pubkey: '{"@type":"/cosmos.crypto.secp256k1.PubKey","key":"AuWW1J8MDbsKcYVFAebqNFhbnmawqwhsMec7sCJ2RivN"}'
  mnemonic: ""


**Important** write this mnemonic phrase in a safe place.
It is the only way to recover your account if you ever forget your password.

sponsor clutch inform search improve save innocent wild click own about fury bench humble dial wink glow bundle tube immune frost barely thunder plunge
root@AX101-FSN174 ~/nibiru #
root@AX101-FSN174 ~/nibiru # nibid keys add $KEY_2_NAME --keyring-backend test

- name: nibi-key-2
  type: local
  address: nibi1lf5f2gxks4rymxyjgn42yqn8wqywxxqmrzjnk3
  pubkey: '{"@type":"/cosmos.crypto.secp256k1.PubKey","key":"A2sF4sU+3iHro9FbywZ9mh8Ra3GGXxbwC1r9QoJfxiCR"}'
  mnemonic: ""


**Important** write this mnemonic phrase in a safe place.
It is the only way to recover your account if you ever forget your password.

churn rack forum almost cycle salon repeat leader duck horn voice burden bench wire advice give flat unfair test kangaroo basket maximum flight image

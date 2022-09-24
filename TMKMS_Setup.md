### Install the following dependencies
```
# RUST
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env

# GCC
sudo apt update
sudo apt install git build-essential ufw curl jq snapd --yes

# Libusb
apt install libusb-1.0-0-dev
```

### Clone repo and setup TMKMS
- Download and install TMKMS
```
# ======================================================================
# The following signing backend providers are presently supported:
# Hardware Security Modules (recommended)
#   - YubiHSM2 (gated under the yubihsm cargo feature. See README.yubihsm.md for more info)
#   - Ledger (gated under the ledgertm cargo feature)
# Software-Only (not recommended)
#   - softsign backend which uses ed25519-dalek
# Guide is for compiling source code using the --features=softsign flag
# ======================================================================
cd $HOME
git clone https://github.com/iqlusioninc/tmkms.git
cd $HOME/tmkms
cargo install tmkms --features=softsign
```
- Initilize TMKMS, then it will generate a `tmkms.toml` file, a `kms-identity.key` (used to authenticate the KMS to the validator), and create 2 subdirectories `secrets` and `state` .
```
tmkms init config
```

- Create a software signing key
```
tmkms softsign keygen ./config/secrets/secret_connection_key
# Generated consensus (Ed25519) private key at: ./config/secrets/secret_connection_key
```

- Upload `priv_validator_key.json` on your validator node to TMKMS node
```
scp root@95.216.21.32:/root/.haqqd/config/priv_validator_key.json /root/tmkms/config/secrets/
```

- Import the private validator key into TMKMS
```
tmkms softsign import $HOME/tmkms/config/secrets/priv_validator_key.json $HOME/tmkms/config/secrets/priv_validator_key
# 2022-09-23T16:08:03.405550Z  INFO tmkms::commands::softsign::import: Imported Ed25519 private key to /root/tmkms/config/secrets/priv_validator_key
```

- Please note at this point, download the file `priv_validator_key.json` to store offline on your computer, then you can delete the file on both your validator node and tmkms node. This newly created `priv_validator_key` will be what TMKMS will use to sign for your validator. 

- Edit `/root/tmkms/config/tmkms.toml` as below to be used for your chain (in this guide i use the chain-id `haqq_54211-2` as example
```
[[chain]]
id = "haqq_54211-2"
key_format = { type = "cosmos-json", account_key_prefix = "haqqpub", consensus_key_prefix = "haqqvalconspub" }
state_file = "/root/tmkms/config/state/priv_validator_state.json"

## Signing Provider Configuration

### Software-based Signer Configuration

[[providers.softsign]]
chain_ids = ["haqq_54211-2"]
key_type = "consensus"
path = "/root/tmkms/config/secrets/priv_validator_key"

## Validator Configuration

[[validator]]
chain_id = "haqq_54211-2"
addr = "tcp://95.216.21.32:688"
secret_key = "/root/tmkms/config/secrets/secret_connection_key"
protocol_version = "v0.34"
reconnect = true
```

- Edit configuration data of your chain on validator node
```
sed -i -E "s|^priv_validator_laddr .*|priv_validator_laddr = \"tcp\:\/\/0\.0\.0\.0\:688\"|" $HOME/.haqqd/config/config.toml
sed -i.bak -E "s|^priv_validator_key_file|# priv_validator_key_file|" $HOME/.haqqd/config/config.toml
sed -i.bak -E "s|^priv_validator_state_file|# priv_validator_state_file|" $HOME/.haqqd/config/config.toml
```

- Stop your validator node
```
systemctl stop haqqd && journalctl -u haqqd -f -o cat
```

- Create systemd of TMKMS, start it, then KMS log will be as below. You can see that consensus key of your validator node has been added to TMKMS (Tip: You can check `pub_key` in original file `priv_validator_key.json`)
```
sudo tee /etc/systemd/system/tmkms.service > /dev/null <<EOF
[Unit]
Description=Tendermint KMS
After=network-online.target

[Service]
User=$USER
ExecStart=$(which tmkms) start -c /root/tmkms/config/tmkms.toml
Restart=on-failure
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable tmkms
sudo systemctl restart tmkms && sudo journalctl -fu tmkms -o cat
```
![image](https://user-images.githubusercontent.com/91453629/192078229-35177f32-e818-43c6-81c6-ad28f427aa62.png)

- Restart your validator node (below is example of haqqd chain)
```
sudo systemctl restart haqqd && sudo journalctl -fu haqqd -o cat
```
![image](https://user-images.githubusercontent.com/91453629/192012024-8a8483ad-ef4a-47fe-a6dd-79bfcfac44dd.png)

- Check TMKMS log, now TMKMS can handshake with validator node and start signing of block
![image](https://user-images.githubusercontent.com/91453629/192043665-e96206f3-1956-4321-98f6-3b4361fc24f3.png)

- Check consensus key of your validator node. 
```
[[ $(haqqd q staking validator haqqvaloper1mc0kvscpucsndf948dnsrrpd954t9l4lfqevk6 -oj | jq -r .consensus_pubkey.key) = $(haqqd status | jq -r .ValidatorInfo.PubKey.value) ]] && echo "You win" || echo "You lose"
```



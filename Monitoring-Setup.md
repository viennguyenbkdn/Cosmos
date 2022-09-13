// Guide is used to setup monitoring and telegram bot alerting on Cosmos chain using docker  
// Credit to KJ89 and Solarlab team  
// Reference: - [Cosmos Node Monitoring](https://github.com/kj89/cosmos_node_monitoring)

## 1. Install exporters on validator node

```
wget -O install_exporters.sh https://raw.githubusercontent.com/kj89/cosmos_node_monitoring/master/install_exporters.sh && chmod +x install_exporters.sh && ./install_exporters.sh
```

| KEY |VALUE |
|---------------|-------------|
| **bond_denom** | Denominated token name, for example, `usei` for sei testnet. You can find it in genesis file: `grep bond_denom /root/.sei/config/genesis.json`
| **bench_prefix** | Prefix for chain addresses, for example, `sei` for sei testnet. You can find it in public addresses like this **sei**_valoper1zyyz4m9ytdf60fn9yaafx7uy7h463n7alv2ete_ |
| **rpc_port** | Your validator `rpc` port that is defined in `config.toml` file, use command `grep -m 1 "^laddr" /root/.sei/config/config.toml` |
| **grpc_port** | Your validator `grpc` port that is defined in `app.toml` file, use command `grep -A 1 "gRPC server address" /root/.sei/config/app.toml` |
| **promethus_port**| Your prometheus port is defined in `config.toml`, use command `grep prometheus_listen /root/.sei/config/config.toml`|

make sure following ports are open:
- `9100` (node-exporter)
- `9300` (cosmos-exporter)

Enable prometheus and expose RPC, restart service after changing. we used Sei for example
```
# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.sei/config/config.toml
# Expose RPC
sed -i.bak -e 's|^laddr = \"tcp:\/\/.*:\([0-9].*\)57\"|laddr = \"tcp:\/\/0\.0\.0\.0:\157\"|' $HOME/.sei/config/config.toml
```

## 2. Monitoring deployment on another machine

_Needs to be deployed on seperate machine to be able to notify in case if validator goes down!_

### 2.1 Install monitoring stack
```
wget -O install_monitoring.sh https://raw.githubusercontent.com/kj89/cosmos_node_monitoring/master/install_monitoring.sh && chmod +x install_monitoring.sh && ./install_monitoring.sh
```
### 2.2 Setup Telegram BOT and configure into monitoring tool

| KEY | VALUE |
|---------------|-------------|
| TELEGRAM_ADMIN | Contact [@userinfobot](https://t.me/userinfobot), then create newbot |
| TELEGRAM_TOKEN | Your telegram bot access token you can get from [@botfather](https://telegram.me/botfather). To generate new token just follow a few simple steps described [here](https://core.telegram.org/bots#6-botfather) | 

Create new tele bot and bot ID, then start   
![image](https://user-images.githubusercontent.com/91453629/189948098-abdd25fd-42cb-45e2-988d-8925565e6e31.png)

Create new API token, then start    
![image](https://user-images.githubusercontent.com/91453629/189949323-50cbfde7-8ef0-4d95-b6a2-7cf89a7182f8.png)

Add bot ID and bot API token into config file
```
sudo cp $HOME/cosmos_node_monitoring/config/.env.example $HOME/cosmos_node_monitoring/config/.env
sudo vim $HOME/cosmos_node_monitoring/config/.env
```
![image](https://user-images.githubusercontent.com/91453629/189950551-3a095dda-fac1-4ac5-a3d3-5ad094cbd352.png)

Export .env file values into environment variable in .bash_profile
```
echo "export $(xargs < $HOME/cosmos_node_monitoring/config/.env)" > $HOME/.bash_profile
source $HOME/.bash_profile
```

### 2.3 Add information of validator node to configuration data

```
VALIDATOR_IP=YOUR_NODE_IP   #10.10.10.10
VALIDATOR_ADDR=YOUR_VALIDATOR_ADDRESS  #seivaloper1j3pzhu2400f4ntv6kznlvramxv62w2d2hj7e4u 
WALLET_ADDRESS=YOUR_WALLER_ADDRESS #sei1j3pzhu2400f4ntv6kznlvramxv62w2d2fa0h5v
PROJECT_NAME=YOUR_PRJ_NAME #Cosmos_Sei

$HOME/cosmos_node_monitoring/add_validator.sh $VALIDATOR_IP $VALIDATOR_ADDR $WALLET_ADDRESS $PROJECT_NAME
```
To add more validators just run command above with validator values. if you wanna modify after running script, edit the file `/root/cosmos_node_monitoring/prometheus/prometheus.yml`, then restart docker

### 2.4 Run docker compose
```
cd $HOME/cosmos_node_monitoring
sudo docker compose up -d
```

Default ports are used to monitor (could be adjusted)
- `8080` (alertmanager-bot)
- `9090` (prometheus)
- `9093` (alertmanager)
- `9999` (grafana)

## 3. Configuration Grafana

### 3.1 Open Grafana
Open Grafana in your web browser, type your IP and port `9999`, default user/pass `àdmin/admin`

![image](https://user-images.githubusercontent.com/50621007/160622455-09af4fbf-2efb-4afb-a8f8-57a2b247f705.png)

### 3.2 Import custom dashboard
Press "+" icon on the left panel and then choose **"Import"**

![image](https://user-images.githubusercontent.com/50621007/160622732-aa9fe887-823c-4586-9fad-4c2c7fdf5011.png)

Input grafana.com dashboard id `15991` and press **"Load"**

![image](https://user-images.githubusercontent.com/50621007/160625753-b9f11287-a3ba-4529-96f9-7c9113c6df3a.png)

Select `Prometheus` data source and press **"Import"**

![image](https://user-images.githubusercontent.com/50621007/160623287-0340acf8-2d30-47e7-8a3a-56295bea8a15.png)



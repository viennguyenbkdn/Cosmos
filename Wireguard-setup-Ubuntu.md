### Installing WireGuard and Generating a Key Pair
```
sudo apt update
sudo apt install wireguard
```

### Create the private key for WireGuard and change its permissions using the following commands
```
su - root
wg genkey | sudo tee /etc/wireguard/private.key
# The sudo chmod go=... command removes any permissions on the file for users and groups other than the root user to ensure that only it can access the private key.
sudo chmod go= /etc/wireguard/private.key

# create the corresponding public key derived from private key
sudo cat /etc/wireguard/private.key | wg pubkey | sudo tee /etc/wireguard/public.key
```

### Select IP Range
- If you are using your WireGuard server with IPv4 peers, the server needs a range of private IPv4 addresses to use for clients, and for its tunnel interface.
- The WireGuard Server will use a single IP address from the range for its private tunnel IPv4 address. We’ll use `10.8.0.1/24` in the range of `10.8.0.1 to 10.8.0.255`

### Creating a WireGuard Server Configuration
- Create new configuration file
```
sudo vim /etc/wireguard/wg0.conf
```

- Add the following lines to the file, substituting your private key in place of the `base64_encoded_private_key_goes_here` value, and the IP address(es) on the `Address` line. You can also change the `ListenPort` line if you would like WireGuard to be available on a different port
```
/etc/wireguard/wg0.conf
[Interface]
PrivateKey = base64_encoded_private_key_goes_here
Address = 10.8.0.1/24
ListenPort = 51820
SaveConfig = true
```

### Adjusting the WireGuard Server’s Network Configuration
```
sudo vim /etc/sysctl.conf
```
- If you are using IPv4 with WireGuard, add the following line at the bottom of the file:
```
net.ipv4.ip_forward=1
```
- If you are using IPv6 with WireGuard, add this line at the bottom of the file:
```
net.ipv6.conf.all.forwarding=1
```

### Configuring the WireGuard Server’s Firewall
* In this section you will edit the WireGuard Server’s configuration to add firewall rules that will ensure traffic to and from the server and clients is routed correctly\
* First find the public network interface of your WireGuard Server using the ip route sub-command:
```
ip route list default
```
* The public interface is the string found within this command’s output that follows the word `dev`. For example, this result shows the interface named `eth0`, which is highlighted below:
```
Output
default via 203.0.113.1 dev eth0 proto static
```
* Open the `/etc/wireguard/wg0.conf`, add firewall rules to your WireGuard Server at the bottom of the file after the `SaveConfig = true` line
```
PostUp = ufw route allow in on wg0 out on eth0
PostUp = iptables -t nat -I POSTROUTING -o eth0 -j MASQUERADE
PostUp = ip6tables -t nat -I POSTROUTING -o eth0 -j MASQUERADE
PreDown = ufw route delete allow in on wg0 out on eth0
PreDown = iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
PreDown = ip6tables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
```
* Configuring the firewall on your WireGuard Server is to allow traffic to and from the WireGuard UDP port itself, also open SSH port
```
sudo ufw allow 51820/udp
sudo ufw allow OpenSSH
```
* Disable and re-enable UFW to restart it, then check status
```
sudo ufw disable
sudo ufw enable
sudo ufw status
```

### Starting the WireGuard Server then check status
```
sudo systemctl enable wg-quick@wg0.service
sudo systemctl start wg-quick@wg0.service
sudo systemctl status wg-quick@wg0.service
```

### Configuring a WireGuard Peer
- Install Wireguard package on client server
```
sudo apt update
sudo apt install wireguard
```
- Creating the WireGuard Peer’s Key Pair
```
wg genkey | sudo tee /etc/wireguard/private.key
sudo chmod go= /etc/wireguard/private.key
sudo cat /etc/wireguard/private.key | wg pubkey | sudo tee /etc/wireguard/public.key
```
- Creating the WireGuard Peer’s Configuration File: Open `/etc/wireguard/wg0.conf`, then edit some info
```
[Interface]
PrivateKey = base64_encoded_peer_private_key_goes_here
Address = 10.8.0.2/24
Address = fd0d:86fa:c3bc::2/64

[Peer]
PublicKey = U9uE2kb/nrrzsEU58GD3pKFU3TLYDMCbetIsnV8eeFE=
AllowedIPs = 10.8.0.0/24, fd0d:86fa:c3bc::/64
Endpoint = 203.0.113.1:51820
```
- Configuring a Peer to Route All Traffic Over the Tunnel
```
# First, you’ll need to determine the IP address that the system uses as its default gateway. Run the following ip route command:

ip route list table main default

# You will receive output like the following:
# Output
# default via 203.0.113.1 dev eth0 proto static
```

#!/bin/bash

# Node ID & Node authen token
# NODE_AUTH_TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJBbGxvdyI6WyJwdWJsaWMiLCJyZWFkIiwid3JpdGUiLCJhZG1pbiJdfQ.mX5sDLDgEHYIiONmAjd-xC5aBvRbOoU2C1MmPbj15ic"
# NODE_ID="12D3KooWMTA3fhNFGXQo14fQPaFduphZbvhsFX2t2SkQfm8NEaAK"
# HOST_IP="94.130.239.162"

# Current uptime of DA node
output=$(curl -s https://leaderboard.celestia.tools/api/v1/nodes/$NODE_ID | jq -r '[.node_id,.uptime] | join(" ")')
echo "$output" | awk '{print "das_owner_node_uptime{instance=\""$1"\", job=\"DAS_Uptime\"} "$2" "}'


# Top 10 Uptime of Fullnode
output=$(curl -s https://leaderboard.celestia.tools/api/v1/nodes/full | jq '.rows | sort_by(-(.uptime | tonumber)) | .[:10]' | jq -r  '.[] | [.node_id,.uptime] | join(" ")')

echo "$output" | awk '{print "das_fullnode_uptime{instance=\""$1"\", job=\"DAS_Uptime\"} "$2" "}'

# Top 10 Uptime of Lightnode
output=$(curl -s https://leaderboard.celestia.tools/api/v1/nodes/light --limit 100000 | jq '.rows | sort_by(-(.uptime | tonumber)) | .[:10]' | jq -r  '.[] | [.node_id,.uptime] | join(" ")')

echo "$output" | awk '{print "das_lightnode_uptime{instance=\""$1"\", job=\"DAS_Uptime\"} "$2" "}'

# Balance of wallet of DA node
ACTION=$(cat <<EOF
{
  "id": 1,
  "jsonrpc": "2.0",
  "method": "state.Balance",
  "params": []
}
EOF
)
Balance=$(curl -s -X POST -H 'Authorization: Bearer '$NODE_AUTH_TOKEN'' -H "Content-Type: application/json" -d "$ACTION" http://$HOST_IP:26658/ | jq .result.amount -r)
echo -e "# Your current balance"
echo -e "balance_da_node{instance=\"$NODE_ID\", job=\"Balances\"} $Balance"

# BandwidthForProtocol returns a Stats struct with bandwidth metrics associated with the given protocol.ID
ACTION=$(cat <<EOF
{
  "id": 1,
  "jsonrpc": "2.0",
  "method": "p2p.BandwidthForProtocol",
  "params": [
    "/celestia/blockspacerace-0/ipfs/bitswap/1.2.0"
  ]
}
EOF
)

BandwidthForProtocol=$(curl -s -X POST -H 'Authorization: Bearer '$NODE_AUTH_TOKEN'' -H "Content-Type: application/json" -d "$ACTION" http://$HOST_IP:26658/ | jq .result -r)
TotalIn=$(echo $BandwidthForProtocol | jq -r .TotalIn)
TotalOut=$(echo $BandwidthForProtocol | jq -r .TotalOut)
RateIn=$(echo $BandwidthForProtocol | jq -r .RateIn)
RateOut=$(echo $BandwidthForProtocol | jq -r .RateOut)

echo -e "# Bandwidth occupied by protocol"
echo -e "bandwidthforprotocol_totalin{instance=\"$NODE_ID\", job=\"BandwidthForProtocol\"} $TotalIn"
echo -e "bandwidthforprotocol_totalout{instance=\"$NODE_ID\", job=\"BandwidthForProtocol\"} $TotalOut"
echo -e "bandwidthforprotocol_ratein{instance=\"$NODE_ID\", job=\"BandwidthForProtocol\"} $RateIn"
echo -e "bandwidthforprotocol_ratein{instance=\"$NODE_ID\", job=\"BandwidthForProtocol\"} $RateOut"


# Peers returns connected peers
ACTION=$(cat <<EOF
{
  "id": 1,
  "jsonrpc": "2.0",
  "method": "p2p.Peers",
  "params": []
}
EOF
)
sleep 1;
connected_peers=$(curl -s -X POST -H 'Authorization: Bearer '$NODE_AUTH_TOKEN'' -H "Content-Type: application/json" -d "$ACTION" http://$HOST_IP:26658/ | jq .result[] -r | wc -l)
echo -e "# Number of connected peers"
echo -e "number_of_connected_peers{instance=\"$NODE_ID\", job=\"Connected_Peers\"} $connected_peers"

#SamplingStats returns the current statistics over the DA sampling process.
ACTION=$(cat <<EOF
{
  "id": 1,
  "jsonrpc": "2.0",
  "method": "das.SamplingStats",
  "params": []
}
EOF
)

failed_sampledblock=$(curl -s -X POST -H 'Authorization: Bearer '$NODE_AUTH_TOKEN'' -H "Content-Type: application/json" -d "$ACTION" http://$HOST_IP:26658/ | jq -r '.result | .failed[]' | wc -l)
result=$(curl -s -X POST -H 'Authorization: Bearer '$NODE_AUTH_TOKEN'' -H "Content-Type: application/json" -d "$ACTION" http://$HOST_IP:26658/ | jq -r '.result.is_running')
da_node_status=0;
if [[ $result == true ]]; then da_node_status=1; fi

echo -e "# Current statistics over the DA sampling process"
echo -e "number_of_failed_sampled_block{instance=\"$NODE_ID\", job=\"SamplingStats\"} $failed_sampledblock"
echo -e "node_running_status{instance=\"$NODE_ID\", job=\"SamplingStats\"} $da_node_status"


### Setting variable
```
CHAIN_ID=haqq_54211-2
WALLET_ADDRESS=haqq1mc0kvscpucsndf948dnsrrpd954t9l4l9z4zjm
WALLET=viennguyen
VALOPER_ADDRESS=haqqvaloper1mc0kvscpucsndf948dnsrrpd954t9l4lfqevk6
VALOPER=viennguyen
instance=haqqd
denom=aISLM
```
### 1. Selfie! 
_Your task is to delegate any number of tokens to your validator._
```
$instance tx staking delegate $VALOPER_ADDRESS 10000000$denom --from=$WALLET --chain-id=$CHAIN_ID --gas=auto --gas-adjustment 1.4 -y
```

### 2. Get yours!
_Your task is to withdraw your validator's rewards to your wallet as well as to any other wallet._
```
# Withdraw all rewards
$instance tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$CHAIN_ID --gas=auto --gas-adjustment 1.4 -y

# Withdraw rewards with commision
$instance tx distribution withdraw-rewards $VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$CHAIN_ID --gas=auto --gas-adjustment 1.4 -y
```

### 3. Help a friend!
_Your task is to delegate any number of tokens to any other validator._
```
DST_VALOPER_ADDRESS=haqqvaloper1mc0k267pucsndf948dns4345351fdfryutyu
$instance tx staking delegate $DST_VALOPER_ADDRESS 10000000$denom --from=$WALLET --chain-id=$CHAIN_ID --gas=auto --gas-adjustment 1.4 -y
```

### 4. Like a squirrel in a wheel!
_Your job is to keep track of your percentage of active validator time._   
At the end of your active set period - take a screenshot and provide it as confirmation. Your uptime should not fall below 98%


### 5. I'm the only one here!
_Decorate your validator (Add an image, add a description, and whatever you see fit)_   
- Login [keybase.io](https://keybase.io/), then register your account, upload photo and create public identity key as below
![image](https://user-images.githubusercontent.com/91453629/190331458-ac899664-bccd-4983-a270-344c78d2e2c6.png)
- Add the above info to your validator
```
KEYBASE_ID=<Copy your ID from keybase.io>
$instance tx staking edit-validator --moniker $VALOPER --identity=$KEYBASE_ID --details="Type anything u want" --chain-id=$CHAIN_ID --from=$WALLET --gas=auto --gas-adjustment 1.4 -y
```

### 6. Law-abiding validator!
_Your task is not to go to jail the entire time you are in the active set._   
To confirm the completion of this task - just confirm it by writing "Jail - this is not about me"

### 7. False alarm!
_To complete this task, you must develop a protection and notification system for your validator._
You can build monitoring system (Grafana & Prometheus), alerting system via TeleBot, Discord Bot or gmail. Build HA/Server cluster

### 8. Can you hear me?
_Your task is not to miss the voting that the team will conduct._
```
PROPOSAL_ID=2 #example
$instance tx gov vote $PROPOSAL_ID yes --chain-id=$CHAIN_ID --from=$WALLET -y
```

### 9. Your opinion!
_Your task is to create a proposal that can reach a quorum and be open to a vote_

### 10. Test of strength!
_Try to disable the validator node that is also in the active set with you._

### 11. I will show you to the whole world!
_To complete this task - you need to write your own explorer or add our network if you already have it_

### 12. Total Strength!
_Try your hand at total network shutdown._

### 13. Work on mistakes!
_Find any inconsistency in our documents and offer to fix it._

### 14. Bug hunter!
_Find bugs in the code on our GitHub and suggest fixes._






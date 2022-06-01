# SoulBound-ERC20
SoulBound ERC20 - Bounty on EthernautDAO

## Bounty Details 
- Implement a setApprovedMinter(address, bool) onlyOwner function 
- No limit on total supply
- Transfer capabilities must be disabled after minting (soulbound)

- Files have been updated to change EXPtoken to my own take that I was working under EXPerienceGame repo
- Current Soulbound implementation also supports API3's QRNG implementation of random numbers 

### Test it
- clone this repo 
```
git clone git@github.com:SolDev-HP/SoulBound-ERC20.git
```

- Setup your python virtual environement (Don't want those deps spilling over to others)
```
python -m venv .venv
```

- Activate your virtual environment
```
python ./.venv/scripts/activate 
```

- Install dependencies, this will install eth-brownie and other required packages
```
pip install -r requirements.txt
```

- Change into project directory 
```
cd EXP_Token
```

- Prepare environment variables, create .env file from .env.example file and add required details
```
cp .env.example .env
```

- If you're using local ganache-cli for deployment, make sure you update following variables inorder for deployement script to run and deploy required contracts 

```
DEV_SADMIM_PUB = ""
DEV_SADMIM_PRIV = ""
DEV_ADMIM2_PUB = ""
DEV_ADMIM2_PRIV = ""
DEV_HODLER1_PUB = ""
DEV_HODLER1_PRIV = ""
DEV_HODLER2_PUB = ""
DEV_HODLER2_PRIV = ""
```

- We are using OpenZeppelin and API3 packages within brownie, hence once inside the token directory, install brownie packages using following commands 
```
brownie pm install OpenZeppelin/openzeppelin-contracts@4.6.0
brownie pm install brownie pm install api3dao/airnode@0.6.3
```
- (note) all brownie does is, looks onto github by following pattern to find requested package version from repo
```
[ORGANIZATION]/[REPOSITORY]@[VERSION]
```

- Compile the project
```
brownie compile 
OR
brownie compile --size (to view contract sizes after compiling)
```

- Deploy on testnet, and perform THE MOST BASIC function (As other functionality tests are still WIP)
```
brownie run .\scripts\deploy_exptoken_local.py --network development 
```

This script performs following steps:
1. Deploys our dummy AirnodeRrpV0 contract, so that while deploying EXPToken, setSponsorshipStatus can be mimicked on local devnet 
2. Deploys EXPToken contract using AirnodeRrp contract address as argument along with token name and symbol 
3. SetTokenAdmin is called on EXPToken by deployer, setting second account as admin
4. Deployer mints some EXP to user1 
5. Admin2 mints some EXP to user2
6. Verify users can't perform admin actions 
7. Verify soulbound functionality 
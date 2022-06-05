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
brownie pm install api3dao/airnode@0.6.3
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
8. Requests random number, (make sure before this happens, you top up sponsor wallet 
- It will be fullfilling all the requests from now on. something like 0.005rEth should be fine.)

### Current Status + Deployment on rinkeby 

- Verify you have .env prepared and above steps followed.

```
[EXPToken]> brownie run .\scripts\deploy_exp_rinkeby.py --network rinkeby
INFO: Could not find files for the given pattern(s).
Brownie v1.16.4 - Python development framework for Ethereum

// All referenced contracts (oz, api3dao) are compiled 
// along with EXPToken, and QRNGRequester 

New compatible solc version available: 0.8.13
Compiling contracts...
  Solc version: 0.8.13
  Optimizer: Enabled  Runs: 200
  EVM Version: Istanbul
Generating build data...
 - OpenZeppelin/openzeppelin-contracts@4.6.0/Ownable
 - OpenZeppelin/openzeppelin-contracts@4.6.0/ERC20
 - OpenZeppelin/openzeppelin-contracts@4.6.0/IERC20
 - OpenZeppelin/openzeppelin-contracts@4.6.0/IERC20Metadata
 - OpenZeppelin/openzeppelin-contracts@4.6.0/Context
 - api3dao/airnode@0.6.3/IAirnodeRrpV0
 - api3dao/airnode@0.6.3/IAuthorizationUtilsV0
 - api3dao/airnode@0.6.3/ITemplateUtilsV0
 - api3dao/airnode@0.6.3/IWithdrawalUtilsV0
 - api3dao/airnode@0.6.3/RrpRequesterV0
 - EXPToken
 - QRNGRequester
 - ISoulbound

ExpTokenProject is the active project.

// Contract deployed 

Running 'scripts\deploy_exp_rinkeby.py::main'...
Transaction sent: 0x3a56751ff07cb06b8f58a7d5c517ed36077b41db9e858f93006aa0edd13c95bf
  Gas price: 1.250000263 gwei   Gas limit: 1153934   Nonce: 220
  EXPToken.constructor confirmed   Block: 10785469   Gas used: 1049031 (90.91%)
  EXPToken deployed at: 0x00382C73b6A1D7A5589625EDB59d8344A6CC3388

// At the same time, internally it does following (from etherscan rinkeby)
// Contract is set as a sponsor as well as requester, so the sponsorship status
// is set to true on airnoderrp

Address     0xa0ad79d995ddeeb18a14eaef56a549a04e3aa1bd
Name        SetSponsorshipStatus (index_topic_1 address sponsor, 
            index_topic_2 address requester, bool sponsorshipStatus)
            View Source

Topics
0 0xc2e532a12bbcce2bfa2ef9e4bee80180e4e1b1f78618f0d20bc49a648b577c56
1  0x00382c73b6a1d7a5589625edb59d8344a6cc3388
2  0x00382c73b6a1d7a5589625edb59d8344a6cc3388
Data
sponsorshipStatus : True

// This generates sponsor wallet that will call fulfill request after randomness 
// is requested, more in the logs below 

Execute this in other teaminal, and save result for the next input box.    
npx @api3/airnode-admin derive-sponsor-wallet-address --airnode-xpub xpub6DXSDTZBd4aPVXnv6Q3SmnGUweFv6j24SK77W4qrSFuhGgi666awUiXakjXruUSCDQhhctVG7AQt67gMdaRAsDnDXv23bBRKsMWvRzo6kbf --airnode-address 0x9d3C147cA16DB954873A498e0af5852AB39139f2 --sponsor-address 0x00382C73b6A1D7A5589625EDB59d8344A6CC3388


Waiting till you get the sponsor address... Press any key once received... 
Enter sponsor Wallet - 0xCCa4eB2CFF47eb01bC1B8a38D84e5674A3A83043

Sponsor wallet received - 0xCCa4eB2CFF47eb01bC1B8a38D84e5674A3A83043       

Trimmed address is now 0xCCa4eB2CFF47eb01bC1B8a38D84e5674A3A83043
Verify sponsor address. We're now setting request params. Press any key to 
continue...

// This is setRequestParameters(...) 
Transaction sent: 0x87367404efd50d8251734107fb76a71b6eb0b7181c7fd295a14f621cbde6a56e
  Gas price: 1.250000263 gwei   Gas limit: 100545   Nonce: 221

// basic erc20 
Transaction sent: 0x6dac5b877ddd2b918d14558c0b32bf637604d359656abce563225137b517a128
  Gas price: 1.250000263 gwei   Gas limit: 53054   Nonce: 222
  EXPToken.setTokenAdmin confirmed   Block: 10785472   Gas used: 48231 (90.91%)

Transaction sent: 0x879909f373781727496e738ea71469df0aabf5c92737a13126c7ba0a8ed09e95
  Gas price: 1.250000263 gwei   Gas limit: 78031   Nonce: 223
  EXPToken.gainExperience confirmed   Block: 10785473   Gas used: 70938 (90.91%)

Transaction sent: 0x805d94497db869b7bc7903f658bcd02c1d239dced550c393abb7f71290ea8ea7
  Gas price: 1.250000263 gwei   Gas limit: 59235   Nonce: 86
  EXPToken.gainExperience confirmed   Block: 10785474   Gas used: 53850 (90.91%)

Transaction sent: 0x88e6b47b6135ed2698345f057f5eab67dd79611475d4770c3419a12baee8c6fd
  Gas price: 1.250000263 gwei   Gas limit: 59235   Nonce: 224
  EXPToken.gainExperience confirmed   Block: 10785475   Gas used: 53850 (90.91%)

Transaction sent: 0x0c4aaa357e8a881abbd0fa450c09f2fbf25d88fad6e3b02c7f5af65e71ed7862
  Gas price: 1.250000263 gwei   Gas limit: 59235   Nonce: 87
  EXPToken.gainExperience confirmed   Block: 10785476   Gas used: 53850 (90.91%)

Transaction sent: 0x551cc7a824d6edac8a9439bc083261b45e762849154bf4e7cd1f3d659efc5af4
  Gas price: 1.250000263 gwei   Gas limit: 59235   Nonce: 225
  EXPToken.gainExperience confirmed   Block: 10785477   Gas used: 53850 (90.91%)

// ramdom number is requested -> madeFullRequest

Transaction sent: 0xa05e8527535d726ef8d7cd1635e6071fc7bf999e6e2c921a0979ca7e6e413c75
  Gas price: 1.250000263 gwei   Gas limit: 126940   Nonce: 226
  EXPToken.requestRandomEXPerienceForPlayer confirmed   Block: 10785478   Gas used: 115400 (90.91%)

// Following above transaction on etherscan 

Address     0xa0ad79d995ddeeb18a14eaef56a549a04e3aa1bd
Name        MadeFullRequest (index_topic_1 address airnode, index_topic_2 bytes32 requestId, 
            uint256 requesterRequestCount, uint256 chainId, address requester, bytes32 endpointId, 
            address sponsor, address sponsorWallet, 
            address fulfillAddress, bytes4 fulfillFunctionId, bytes parameters)
            View Source

Topics
0 0x3a52c462346de2e9436a3868970892956828a11b9c43da1ed43740b12e1125ae
1  0x9d3c147ca16db954873a498e0af5852ab39139f2
2  8AFB3B7B0F89FAF630AFB2598C0B2C632EE523E4A58D8BDEC4BE59D599820F62
Data
requesterRequestCount : 1      
chainId : 4                 // Rinkeby
requester : 0x00382c73b6a1d7a5589625edb59d8344a6cc3388  // EXPToken Contract
endpointId : FB6D017BB87991B7495F563DB3C8CF59FF87B09781947BB1E417006AD7F55A78 // uint256 endpoint path
sponsor : 0x00382c73b6a1d7a5589625edb59d8344a6cc3388    // EXPToken contract 
sponsorWallet : 0xcca4eb2cff47eb01bc1b8a38d84e5674a3a83043 // Sponsor wallet (fulfillment caller)
fulfillAddress : 0x00382c73b6a1d7a5589625edb59d8344a6cc3388 // where fulfillment fn resides (EXPToken contract )
fulfillFunctionId : 911A52BA // (function selector)
parameters : 


Verify that the transaction went through. Wait for randomness fulfillment to occur. And then Press any key to continue...

// Perform remaining verification and interaction by brownie console.
// Following is some way you can interact with your recently deployed (or any in the history, for that matter) contract 

[~]> brownie console --network rinkeby
INFO: Could not find files for the given pattern(s).
Brownie v1.16.4 - Python development framework for Ethereum

New compatible solc version available: 0.8.13
Compiling contracts...
  Solc version: 0.8.13
  Optimizer: Enabled  Runs: 200
  EVM Version: Istanbul
Generating build data...
 - OpenZeppelin/openzeppelin-contracts@4.6.0/Ownable
 - OpenZeppelin/openzeppelin-contracts@4.6.0/ERC20
 - OpenZeppelin/openzeppelin-contracts@4.6.0/IERC20
 - OpenZeppelin/openzeppelin-contracts@4.6.0/IERC20Metadata
 - OpenZeppelin/openzeppelin-contracts@4.6.0/Context
 - api3dao/airnode@0.6.3/IAirnodeRrpV0
 - api3dao/airnode@0.6.3/IAuthorizationUtilsV0
 - api3dao/airnode@0.6.3/ITemplateUtilsV0
 - api3dao/airnode@0.6.3/IWithdrawalUtilsV0
 - api3dao/airnode@0.6.3/RrpRequesterV0
 - EXPToken
 - QRNGRequester
 - ISoulbound

ExpTokenProject is the active project.
Brownie environment is ready.
>>> expcon = EXPToken[-1]
>>> expcon.info
<bound method _ContractBase.info of <EXPToken Contract '0x00382C73b6A1D7A5589625EDB59d8344A6CC3388'>>
>>> expcon.info()
>>> expcon.selectors
{
    '0x06fdde03': "name",
    '0x095ea7b3': "approve",      
    '0x18160ddd': "totalSupply",  
    '0x23b872dd': "transferFrom", 
    '0x313ce567': "decimals",     
    '0x3789f8d1': "setTokenAdmin",
    '0x39509351': "increaseAllowance",
    '0x491aa51d': "aSponsorWallet",
    '0x70a08231': "balanceOf",
    '0x715018a6': "renounceOwnership",
    '0x71bab666': "airnodeRrp",
    '0x7bdf2525': "setRequestParameters",
    '0x8da5cb5b': "owner",
    '0x911a52ba': "fulfillRandomNumberRequest",
    '0x95d89b41': "symbol",
    '0xa457c2d7': "decreaseAllowance",
    '0xa9059cbb': "transfer",
    '0xc2baa2dc': "aApiProviderAirnode",
    '0xcb2328bb': "btEndpointIdUint256",
    '0xccbac9f5': "randomNumber",
    '0xd9909f05': "requestRandomEXPerienceForPlayer",
    '0xdd62ed3e': "allowance",
    '0xf2fde38b': "transferOwnership",
    '0xf56bbc9c': "gainExperience",
    '0xfd2413f8': "mTokenAdmins"
}
>>> dir(expcon)
[aApiProviderAirnode, aSponsorWallet, abi, address, airnodeRrp, alias, allowance, 
approve, balance, balanceOf, btEndpointIdUint256, bytecode, decimals, decode_input, 
decreaseAllowance, from_abi, from_ethpm, from_explorer, fulfillRandomNumberRequest, 
gainExperience, get_method, get_method_object, increaseAllowance, info, mTokenAdmins, 
name, owner, randomNumber, renounceOwnership, requestRandomEXPerienceForPlayer, selectors,
setRequestParameters, setTokenAdmin, set_alias, signatures, symbol, topics, totalSupply, 
transfer, transferFrom, transferOwnership, tx]

>>> accounts.add('****')
<LocalAccount '0xBcE03a4B33337E4776d845909C041CAAD4799790'>
>>> tx1 = expcon.requestRandomEXPerienceForPlayer('0x0B713A8711FE023D9a8b1eF48F63EB2Fe2c4A559', {'from': accounts[0]})
Transaction sent: 0x20bc11cf8b883fd9477c6373964b99372d65517e57d69a107ea0361f6a664533
  Gas price: 1.250000263 gwei   Gas limit: 126940   Nonce: 227
  EXPToken.requestRandomEXPerienceForPlayer confirmed   Block: 10785497   Gas used: 115400 (90.91%)

>>> tx1.info()
Transaction was Mined
---------------------
Tx Hash: 0x20bc11cf8b883fd9477c6373964b99372d65517e57d69a107ea0361f6a664533
From: 0xBcE03a4B33337E4776d845909C041CAAD4799790
To: 0x00382C73b6A1D7A5589625EDB59d8344A6CC3388
Value: 0
Function: EXPToken.requestRandomEXPerienceForPlayer
Block: 10785497
Gas Used: 115400 / 126940 (90.9%)

Events In This Transaction
--------------------------
├── 0xa0AD79D995DdeeB18a14eAef56A549A04e3Aa1Bd
│   └── MadeFullRequest
│       ├── airnode: 0x9d3C147cA16DB954873A498e0af5852AB39139f2
│       ├── requestId: 0x0c5360fa29d558718029a181666ff48bbe0944c9afd1e0316837add094b79559
│       ├── requesterRequestCount: 2
│       ├── chainId: 4
│       ├── requester: 0x00382C73b6A1D7A5589625EDB59d8344A6CC3388
│       ├── endpointId: 0xfb6d017bb87991b7495f563db3c8cf59ff87b09781947bb1e417006ad7f55a78
│       ├── sponsor: 0x00382C73b6A1D7A5589625EDB59d8344A6CC3388
│       ├── sponsorWallet: 0xCCa4eB2CFF47eb01bC1B8a38D84e5674A3A83043      
│       ├── fulfillAddress: 0x00382C73b6A1D7A5589625EDB59d8344A6CC3388     
│       ├── fulfillFunctionId: 0x911a52ba
│       └── parameters: 0x00
│
└── EXPToken (0x00382C73b6A1D7A5589625EDB59d8344A6CC3388)
    └── RandomNumberRequested
        └── btRequestId: 0x0c5360fa29d558718029a181666ff48bbe0944c9afd1e0316837add094b79559

// Current bycode size 

============ Deployment Bytecode Sizes ============
  AirnodeRrpV0          -   6,467B  (26.31%)
  EXPToken              -   3,746B  (15.24%)
  TemplateUtilsV0       -   2,440B  (9.93%)
  ERC20                 -   2,182B  (8.88%)
  QRNGRequester         -   1,643B  (6.69%)
  AuthorizationUtilsV0  -   1,541B  (6.27%)
  WithdrawalUtilsV0     -   1,132B  (4.61%)
  RrpRequesterV0        -     165B  (0.67%)

>>> Noooiiicceeee!!! :')
```

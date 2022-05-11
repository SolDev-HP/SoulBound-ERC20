# SoulBound-ERC20
SoulBound ERC20 - Bounty on EthernautDAO

## Bounty Details 
- Implement a setApprovedMinter(address, bool) onlyOwner function 
- No limit on total supply
- Transfer capabilities must be disabled after minting (soulbound)

## Inspiration Refs:
- https://github.com/kethcode/exp 
- https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol
- https://github.com/Rari-Capital/solmate/blob/main/src/tokens/ERC20.sol

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
- Install dependencies 
```
pip install -r requirements.txt
```
- Prepare environment variables, interact.py uses dotenv to load enviroment variables written within .env file 
-- Create .env file and add following 
```
PRIVATE_KEY_SUPERADMIN = "" # This guy can add other admins, and those other admins can mint/burn but can't add further admins 
PRIVATE_KEY_ADMIN2 = ""
PRIVATE_KEY_BUYER1 = ""
PRIVATE_KEY_BUYER2 = ""
```
-- Now you could potentially add Infura or any other node provider's credentials to access repsten/rinkeby or any other chain for that matter
-- Here's the example
```
INFURA_PROVIDER = ""
WEB3_INFURA_PROJECT_ID = ""
INFURA_SECRET = ""
```

-- .env file will be used in interact.py, we load those accounts using private keys (I've used ganache-cli for local development)
- Compile contracts using brownie (Compiles all the contracts present in /contract folder)
```
brownie compile 
```
- Run interact.py script
  - This script deploys EXP contract using Admin1 
  - Admin1 adds another admin called Admin2
  - Admin1 Mints EXP tokens to Admin1
  - Admin2 Mints EXP tokens to Admin2 
  - Casually checks whether buyer1/buyer2 can call restricted functions like setApprovedMinter()
  - Admins mint a few tokens for buyer1/buyer2 
  - Script further demonstrates that both buyers can't transfer the token, not even admin can transfer the token (SoulBound - Once minted and assigned, can't be transfered/moved)

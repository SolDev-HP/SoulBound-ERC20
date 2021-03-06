# This is specifically for deploying ERC20 EXPToken on Rinkeby 
# with the support of QRNG randomness. 
import os 
from brownie import EXPToken, accounts
from dotenv import load_dotenv
load_dotenv()

def main():
    # =========================== Accounts Setup =====================================
    # As usual, take our admin account from rinkeby list 
    admin_account = accounts.add(os.getenv("PRIVATE_KEY_SADMIN"))
    second_admin = accounts.add(os.getenv("PRIVATE_KEY_ADMIN2"))

    # Public hodlers 
    hodler1 = os.getenv("PUBLIC_KEY_HODLER1")
    hodler2 = os.getenv("PUBLIC_KEY_HODLER2")
    hodler3 = os.getenv("PUBLIC_KEY_HODLER3")
    hodler4 = os.getenv("PUBLIC_KEY_HODLER4")
    hodler5 = os.getenv("PUBLIC_KEY_HODLER5")

    # =========================== Airnode + QRNG Setup =====================================
    # Deploy EXPToken contract with airnodeRrp address 
    _airnodeRrpAddress = os.getenv("FOR_QRNG_AIRNODE_RRP_RINKEBY")
    expContract = EXPToken.deploy("EXPToken", "EXP", _airnodeRrpAddress, {"from": admin_account})

    # Now we need to set parameters for randomness first so 
    # that we can make requests for randomness and check API3's QRNG
    # Airnode service provider's address 
    # ANU Quantum Random Numbers - API Provider
    _airnode_address = os.getenv("FOR_QRNG_AIRNODE_ADDRESS")
    # Airnode's extended public key - listed on the same provider api page
    _airnode_xpub = os.getenv("FOR_QRNG_AIRNODE_XPUB")
    # EXPToken contract's address
    _expContract_address = str(expContract)

    # Let's try and call npx to get out sponsor wallet. This shouldn't happen 
    # every time. It's a one time call to setting the params in deployed contract.
    # we need npm package airnode-admin to execute this. Make sure you have that 
    # Current problem with this is --- It starts this subprocess from external python's libs 
    # However, we want this to run in current context and venv so that we can point it correctly to 
    # airnode-admin package for sponsor wallet generation.
    
    # subProc = subprocess.Popen('npx @api3/airnode-admin derive-sponsor-wallet-address --airnode-xpub ' + _airnode_xpub + ' --airnode-address ' + _airnode_address + ' --sponsor-address ' + _expContract_address, stdout=subprocess.PIPE)
    print('\nExecute this in other teaminal, and save result for the next input box.\nnpx @api3/airnode-admin derive-sponsor-wallet-address --airnode-xpub ' + _airnode_xpub + ' --airnode-address ' + _airnode_address + ' --sponsor-address ' + _expContract_address)
    input("\n\nWaiting till you get the sponsor address... Press any key once received...")
    # sponsorWalletResult = subProc.stdout.read()
    sponsorWalletResult = input("Enter sponsor Wallet - ")

    print(f'\nSponsor wallet received - {sponsorWalletResult}')
    # The output result should be something like 
    # Sponsor wallet address: 0xADDress 
    # So we need to cutdown extra part and get the wallet address from the result 
    # ----- Get wallet address 

    _endpointIdUint256 = os.getenv("FOR_QRNG_AIRNODE_ENDPOINT_ID")
    # To generate sponsorWallet, we need to request it using airnode-admin cli,
    # It expects airnode_xpub + airnode_address + sponsor_address (EXPToken contract's address) 
    # Since ethereum address is 40 hex characters, we take the 40 chars from end 
    _sponsorWallet = '0x' + sponsorWalletResult[-40:] # Trimmed from sponsorWalletResults
    
    # verify 
    print(f'\nTrimmed address is now {_sponsorWallet}')
    input("Verify sponsor address. We're now setting request params. Press any key to continue...")
   
    # This should finally allow us to set our sponsor wallet within EXPToken contract 
    expContract.setRequestParameters(_airnode_address, _endpointIdUint256, _sponsorWallet, {"from": admin_account})

    # =========================== Basic ERC20 Interactions =====================================
    # Once that is set, setup some accounts to very basic ERC20 workings 
    # Add another admin
    expContract.setTokenAdmin(os.getenv("PUBLIC_KEY_ADMIN2"), True, {"from": admin_account})
    # Level 1 checking 
    try:
        expContract.gainExperience(hodler1, 1 * 10 ** 18, {"from": admin_account})
        # Mint some EXP to Hodler2 from Admin2 - Level 2 checking 
        expContract.gainExperience(hodler2, 24 * 10 ** 18, {"from": second_admin})
        # Mint some EXP to Hodler2 from Admin2 - Level 3 checking 
        expContract.gainExperience(hodler3, 53 * 10 ** 18, {"from": admin_account})
        # Mint some EXP to Hodler2 from Admin2 - Level 4 checking
        expContract.gainExperience(hodler4, 73 * 10 ** 18, {"from": second_admin})
        # Mint some EXP to Hodler2 from Admin2 - Level 2 checking 
        expContract.gainExperience(hodler5, 95 * 10 ** 18, {"from": admin_account})
    except:
        print("\nDont expect these to fail. but they occasionally do. Dont stop there")

    # Two more accounts which will be tested for random number generation and experience assignment 
    hodler6 = os.getenv("HOLDER6_RINKBY_PUB")
    hodler7 = os.getenv("HOLDER7_RINKBY_PUB")
    hodler8 = os.getenv("HOLDER8_RINKBY_PUB")

    # =========================== Randomness Checks =====================================
    # Add some tests here to verfiy

    """
    - Once this EXPToken contract is deployed 
    --- go to brownie console using `brownie console --network rinkeby` command 
    --- Get the latest deployment Contract/Project object into a var for future reference 
    --- print contract.info().
    
    EX:
    Transaction was Mined
    ---------------------
    Tx Hash: 0x20bc11cf8b883fd9477c6373964b99372d65517e57d69a107ea0361f6a664533From: 0xBcE03a4B33337E4776d845909C041CAAD4799790
    To: 0x00382C73b6A1D7A5589625EDB59d8344A6CC3388
    Value: 0
    Function: EXPToken.requestRandomEXPerienceForPlayer
    Block: 10785497
    Gas Used: 115400 / 126940 (90.9%)

    Events In This Transaction
    --------------------------
    ????????? 0xa0AD79D995DdeeB18a14eAef56A549A04e3Aa1Bd
    ???   ????????? MadeFullRequest
    ???       ????????? airnode: 0x9d3C147cA16DB954873A498e0af5852AB39139f2
    ???       ????????? requestId: 0x0c5360fa29d558718029a181666ff48bbe0944c9afd1e0316837add094b79559
    ???       ????????? requesterRequestCount: 2
    ???       ????????? chainId: 4
    ???       ????????? requester: 0x00382C73b6A1D7A5589625EDB59d8344A6CC3388
    ???       ????????? endpointId: 0xfb6d017bb87991b7495f563db3c8cf59ff87b09781947bb1e417006ad7f55a78
    ???       ????????? sponsor: 0x00382C73b6A1D7A5589625EDB59d8344A6CC3388
    ???       ????????? sponsorWallet: 0xCCa4eB2CFF47eb01bC1B8a38D84e5674A3A83043      
    ???       ????????? fulfillAddress: 0x00382C73b6A1D7A5589625EDB59d8344A6CC3388     
    ???       ????????? fulfillFunctionId: 0x911a52ba
    ???       ????????? parameters: 0x00
    ???
    ????????? EXPToken (0x00382C73b6A1D7A5589625EDB59d8344A6CC3388)
        ????????? RandomNumberRequested
            ????????? btRequestId: 0x0c5360fa29d558718029a181666ff48bbe0944c9afd1e0316837add094b79559


    --- Now you can add the account PRIVATE_KEY_SADMIN into brownie accounts 
    --- `accounts.add('PRIVATE_KEY_SADMIN')
    --- now you can request for random exp for players + gain experience for any player and more (cmd `dir(expConVar)` to know all the methods)

    EX:

    tx1 = expcon.requestRandomEXPerienceForPlayer('0x0B713A8711FE023D9a8b1F48F63EB2Fe2c4A559', {'from': accounts[0]})
    Transaction sent: 0x20bc11cf8b883fd9477c6373964b99372d65517e57d69a107ea0361f6a664533
    Gas price: 1.250000263 gwei   Gas limit: 126940   Nonce: 227
    EXPToken.requestRandomEXPerienceForPlayer confirmed   Block: 10785497   Gas used: 115400 (90.91%)

    """

    # expContract.randomNumber({"from": admin_account})       # This should be zero
    # Request some random experience for the player 
    # Note, the fulfillment function is still external, very much controlled by 
    # airnode's fulfiller. We can't really mint under a function that can be called 
    # by airnode for fulfillment - Though, what would be the risk if we do that? (Research more)
    # This also requires gasPrice indication. Because if we don't supply, it throw valueError 
    # stating it can't estimate gas 
    expContract.requestRandomEXPerienceForPlayer(hodler6, {"from": admin_account})
    # Verify
    input("\nVerify that the transaction went through. Wait for randomness fulfillment to occur. And then Press any key to continue...")
    # Read the randomnumber again, it should've changed with the fulfilled data 
    print('\nRandom number after request')
    print(expContract.randomNumber({"from": admin_account}))
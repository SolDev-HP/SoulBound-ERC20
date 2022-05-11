import os
import os
from brownie import Contract, accounts, EXP, exceptions
from dotenv import load_dotenv
load_dotenv()

def main():
    adminAccount = accounts.add(os.getenv("PRIVATE_KEY_SUPERADMIN"))
    admin2Account = accounts.add(os.getenv("PRIVATE_KEY_ADMIN2"))
    buyerAccount = accounts.add(os.getenv("PRIVATE_KEY_BUYER1"))
    buyer2Account = accounts.add(os.getenv("PRIVATE_KEY_BUYER2"))
    expContract =  EXP.deploy("EXP", "EXP", 18, {"from": adminAccount})#Contract("0x0B43D16f013B2d25E25Dd5dF20182aD5563ca85c", "EXP")

    # Check balances 
    printBal(expContract, adminAccount, "[Admin]")
    printBal(expContract, admin2Account, "[Admin2]")
    printBal(expContract, buyerAccount, "[Buyer]")
    printBal(expContract, buyer2Account, "[Buyer2]")
    # Setting another admin 
    expContract.setApprovedMinter(admin2Account, True, {"from": adminAccount})

    # Testing if any other callers can call this function
    # should fail/revert
    try:
        expContract.setApprovedMinter(buyerAccount, True, {"from": buyerAccount})
    except:
        print(f"Expected exception")

    try:
        expContract.setApprovedMinter(buyerAccount, True, {"from": buyer2Account})
    except:
        print(f"Expected exception")

    # Admin mints a few tokens to himself 
    expContract.mint(adminAccount, 100 * 10**18, {"from": adminAccount})
    # Admin2 mints to himself 
    expContract.mint(admin2Account, 100 * 10**18, {"from": admin2Account})
    # Admin1 -> Admin2
    expContract.mint(admin2Account, 100 * 10**18, {"from": adminAccount})
    # Admin2 -> Admin1
    expContract.mint(adminAccount, 100 * 10**18, {"from": admin2Account})
    # Admin1 -> Buyer
    expContract.mint(buyerAccount, 100 * 10**18, {"from": adminAccount})
    # Admin2 -> Buyer2
    expContract.mint(buyer2Account, 100 * 10**18, {"from": adminAccount})

    # Check balances 
    printBal(expContract, adminAccount, "[Admin]")
    printBal(expContract, admin2Account, "[Admin2]")
    printBal(expContract, buyerAccount, "[Buyer]")
    printBal(expContract, buyer2Account, "[Buyer2]")

    try:
        # Buyer tries to transfer - Should fail/revert with SoulBoundRestriction
        expContract.transfer(buyer2Account, 50 * 10**18, {"from": buyerAccount})
    except:
        print(f"Expected exception")

    print("------------------------------")

    try:
        # Even admin tries to transfer - Should fail/revert 
        expContract.trasnfer(adminAccount, 50 * 10**18, {"from": adminAccount})
    except:
        print(f"Expected exception")

    # Check balances 
    printBal(expContract, adminAccount, "[Admin]")
    printBal(expContract, admin2Account, "[Admin2]")
    printBal(expContract, buyerAccount, "[Buyer]")
    printBal(expContract, buyer2Account, "[Buyer2]")

def printBal(contract, account, type):
    print(f"Account {type} EXP Balance: {contract.balanceOf(account)}")
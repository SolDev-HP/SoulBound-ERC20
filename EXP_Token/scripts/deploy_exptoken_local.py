import os, sys
_loggerPath = os.path.abspath("./scripts/")
sys.path.append(_loggerPath)
import _logprinter as Logs
from brownie import accounts, EXPToken, AirnodeRrpV0
from dotenv import load_dotenv
load_dotenv()

def main():
    # EXPToken deployment requires, name (string), symbol (string)
    # and AirnodeRrp's address on chain
    # Reference: https://docs.api3.org/qrng/chains.html
    dev_deployer = accounts.add(os.getenv("DEV_SADMIM_PRIV"))
    dev_admin2 = accounts.add(os.getenv("DEV_ADMIM2_PRIV"))
    dev_hodler1 = accounts.add(os.getenv("DEV_HODLER1_PRIV"))
    dev_hodler2 = accounts.add(os.getenv("DEV_HODLER2_PRIV"))

    # First deploy our dummy QRNG test for local 
    qrngTestCon = AirnodeRrpV0.deploy({"from": dev_deployer})
    # Now we can use qrngTestCon address as param for EXPToken 
    # and deploy on local devnet
    expContract = EXPToken.deploy("EXPToken", "EXP", str(qrngTestCon), {"from": dev_deployer})

    # Add another admin
    expContract.setTokenAdmin(os.getenv("DEV_ADMIM2_PUB"), True, {"from": dev_deployer})
    # Mint some EXP to Hodler1 from Admin1
    # It's like adding a new user to play the game. Every user starts with 1 EXP minted by admin for them
    expContract.gainExperience(os.getenv("DEV_HODLER1_PUB"), 1, {"from": dev_deployer})
    # Mint some EXP to Hodler2 from Admin2 
    expContract.gainExperience(os.getenv("DEV_HODLER2_PUB"), 1 * 10 ** 18, {"from": dev_admin2})

    # Need to test more functions like transfer/approve/fallback/receive
    # Hodler1 tries to gain/loose experience 
    try:
        expContract.gainExperience(os.getenv("DEV_HODLER1_PUB"), 1 * 10 ** 18, {"from": dev_hodler1}) #should fail
    except BaseException as err:
        Logs.logExceptionMakeReadable(err)

    # Hodler1 tries to tranfer/approve 
    try:
        expContract.transfer(os.getenv("DEV_HODLER2_PUB"), 1 * 10 ** 18, {"from": dev_hodler1}) #should fail
    except BaseException as err:
        Logs.logExceptionMakeReadable(err)

    # Same as hodler2
    try: 
        expContract.approve(os.getenv("DEV_HODLER1_PUB"), 1 * 10 ** 18, {"from": dev_hodler1}) #should fail
    except BaseException as err:
        Logs.logExceptionMakeReadable(err)

    # Trying QRNG predictable replies locally
    try:
        expContract.requestRandomEXPerienceForPlayer(os.getenv("DEV_HODLER2_PUB"), {"from": dev_deployer})
    except BaseException as err:
        Logs.logExceptionMakeReadable(err)
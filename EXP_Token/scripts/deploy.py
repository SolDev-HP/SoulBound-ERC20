import os
from brownie import accounts, EXP
from dotenv import load_dotenv
load_dotenv()

def main():
    account = accounts.add(os.getenv("PRIVATE_KEY"))
    expAdd = EXP.deploy("EXP", "EXP", 18, {"from": account})
from ape import accounts, project, networks

def main():
    with networks.parse_network_choice("ethereum:mainnet:alchemy") as provider:
        acct = accounts.load("deployer_account")
        print(acct.address, acct.balance)
        compass = "0x652Bf77d9F1BDA15B86894a185E8C22d9c722EB4"  # new compass eth-main
        reward = "0xdAC17F958D2ee523a2206206994597C13D831ec7"   # USDT
        factory = "0x82E2c99AD31e6119D874B08fbd2C3f9F9fbD1aD8"  # need to wait for the curve healthy juice bot
        admin = "0xF48F4e86dE6a30D75dbe3A6C67E17Cf3cbDE5768"
        
        competitionEth = project.competitionEth.deploy(compass, reward, factory, admin, sender=acct)
        print(competitionEth)


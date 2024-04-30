from ape import accounts, project, networks

def main():
    with networks.parse_network_choice("arbitrum:mainnet:alchemy") as provider:
        acct = accounts.load("deployer_account")
        print(acct.balance)
        compass = "0x1F6dD66D5dFAB320266864F09c4a0497ee4b7818"  # new compass address arbitrum-main
        competitionArb = project.competitionArb.deploy(compass, sender=acct)
        print(competitionArb)


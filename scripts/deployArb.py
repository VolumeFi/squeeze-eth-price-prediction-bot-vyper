from ape import accounts, project, networks

def main():
    with networks.parse_network_choice("arbitrum:mainnet:alchemy") as provider:
        acct = accounts.load("deployer_account")
        print(acct.balance)
        compass = "0x05d7b3A021DAFA1A52Aef09B8057493847cb6800"
        competitionArb = project.competitionArb.deploy(compass, sender=acct)
        print(competitionArb)


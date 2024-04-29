from ape import accounts, project, networks

def main():
    with networks.parse_network_choice("ethereum:mainnet:alchemy") as provider:
        acct = accounts.load("deployer_account")
        print(acct.balance)
        compass = ""
        reward = "0xdAC17F958D2ee523a2206206994597C13D831ec7"   # USDT
        decimals = 6
        factory = "0x5ae3ea1d72cAb91ADfBc7E95e879b729D3ebDD03"
        competitionEth = project.competitionEth.deploy(compass, reward, decimals, factory, sender=acct)
        print(competitionEth)


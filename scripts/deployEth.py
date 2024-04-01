from ape import accounts, project, networks

def main():
    with networks.parse_network_choice("ethereum:mainnet:alchemy") as provider:
        acct = accounts.load("deployer_account")
        print(acct.balance)
        compass = "0xB01cC20Fe02723d43822819ec57fCbadf31f1537"
        reward = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"
        decimals = 6
        factory = "0x5ae3ea1d72cAb91ADfBc7E95e879b729D3ebDD03"
        competitionEth = project.competitionEth.deploy(compass, reward, decimals, factory, sender=acct)
        print(competitionEth)


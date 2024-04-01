from ape import accounts, project

acct = accounts.load("deployer_account")
compass = "0xB01cC20Fe02723d43822819ec57fCbadf31f1537"
reward = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"
decimals = 6
factory = ""
competitionEth = project.competitionEth.deploy(compass, reward, decimals, factory, sender=acct)
print(competitionEth)


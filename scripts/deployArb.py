from ape import accounts, project

acct = accounts.load("deployer_account")
compass = "0x05d7b3A021DAFA1A52Aef09B8057493847cb6800"

competitionArb = project.competitionArb.deploy(compass, sender=acct)
print(competitionArb)


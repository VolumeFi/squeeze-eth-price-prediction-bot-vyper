import ape
import pytest
from eth_abi import encode
from web3 import Web3

@pytest.fixture(scope="session")
def Deployer(accounts):
    return accounts[0]

@pytest.fixture(scope="session")
def Admin(accounts):
    return accounts[1]

@pytest.fixture(scope="session")
def Alice(accounts):
    return accounts[2]

@pytest.fixture(scope="session")
def Compass(accounts):
    return accounts[3]

@pytest.fixture(scope="session")
def USDT(Deployer, project):
    return Deployer.deploy(project.testToken, "USDT", "USDT", 6, 10000000000000)

@pytest.fixture(scope="session")
def CompetitionEth(Deployer, project, Compass, USDT, Alice, Admin):
    
    contract = Deployer.deploy(project.competitionEth, Compass, USDT, Alice, Admin)
    funcSig = function_signature("set_paloma()")
    addPayload = encode(["bytes32"], [b'123456'])
    payload = funcSig + addPayload
    contract(sender=Compass, data=payload)

    return contract

@pytest.fixture(scope="session")
def CompetitionArb(Deployer, project, Compass):

    contract = Deployer.deploy(project.competitionArb, Compass)
    funcSig = function_signature("set_paloma()")
    addPayload = encode(["bytes32"], [b'123456'])
    payload = funcSig + addPayload
    contract(sender=Compass, data=payload)

    return contract

def function_signature(str):
    return Web3.keccak(text=str)[:4]

def test_add():
    assert 1 + 1 == 2

def test_competition_arb(Deployer, accounts, CompetitionArb, Compass, Alice, chain):
    assert Deployer == accounts[0]

    func_sig = function_signature(
        "set_active_epoch((uint256,uint256,uint256,uint256,uint256))")
    enc_abi = encode(["(uint256,uint256,uint256,uint256,uint256)"], [(1, 1716249600, 1716336000, 0, 10000000)])
    add_payload = encode(["bytes32"], [b'123456'])
    payload = func_sig + enc_abi + add_payload
    CompetitionArb(sender=Compass, data=payload)

    assert CompetitionArb.epoch_info().epoch_id == 1
    assert CompetitionArb.epoch_info().competition_start == 1716249600
    assert CompetitionArb.epoch_info().competition_end == 1716336000
    assert CompetitionArb.epoch_info().entry_cnt == 0
    assert CompetitionArb.epoch_info().prize_amount == 10000000

    with ape.reverts():
        CompetitionArb.bid(3000, sender=Alice)

    chain.pending_timestamp += 86400
    CompetitionArb.bid(3000, sender=Alice)
    assert CompetitionArb.epoch_info().entry_cnt == 1

    with ape.reverts():
        CompetitionArb.bid(4000, sender=Alice)

    with ape.reverts():
        CompetitionArb(sender=Compass, data=payload)

    enc_abi = encode(["(uint256,uint256,uint256,uint256,uint256)"], [(2, 1715731200, 1716422400, 0, 500)])
    add_payload = encode(["bytes32"], [b'123456'])
    payload = func_sig + enc_abi + add_payload
    CompetitionArb(sender=Compass, data=payload)

    chain.pending_timestamp += 86400
    CompetitionArb.bid(5000, sender=Alice)
    CompetitionArb.bid(3000, sender=Deployer)
    assert CompetitionArb.bid_info(0).epoch_id == 2
    assert CompetitionArb.bid_info(1).epoch_id == 2

    assert CompetitionArb.epoch_info().entry_cnt == 2

    assert CompetitionArb.my_info(1, Alice) == 3000
    assert CompetitionArb.my_info(2, Alice) == 5000
    assert CompetitionArb.my_info(1, Deployer) == 0
    assert CompetitionArb.my_info(2, Deployer) == 3000
    
def test_competition_eth(Deployer, accounts, USDT, CompetitionEth, Admin, Compass):
    assert Deployer == accounts[0]

    assert CompetitionEth.epoch_cnt() == 0
    USDT.approve(CompetitionEth.address, 1000000000, sender=Deployer)
    receipt = CompetitionEth.send_reward(1000000000, 1, sender=Deployer)
    assert not receipt.failed
    assert CompetitionEth.epoch_cnt() == 1
    assert CompetitionEth.active_epoch_num() == 1
    
    USDT.approve(CompetitionEth.address, 4000000000, sender=Deployer)
    receipt = CompetitionEth.send_reward(2000000000, 2, sender=Deployer)
    assert not receipt.failed
    assert CompetitionEth.epoch_cnt() == 3

    USDT.approve(CompetitionEth.address, 3000000000, sender=Deployer)
    receipt = CompetitionEth.send_reward(1000000000, 3, sender=Deployer)
    assert not receipt.failed
    assert CompetitionEth.epoch_cnt() == 6

    USDT.approve(CompetitionEth.address, 4000000000, sender=Deployer)
    receipt = CompetitionEth.send_reward(1000000000, 4, sender=Deployer)
    assert not receipt.failed
    assert CompetitionEth.epoch_cnt() == 10

    USDT.approve(CompetitionEth.address, 5000000000, sender=Deployer)
    receipt = CompetitionEth.send_reward(1000000000, 5, sender=Deployer)
    assert not receipt.failed
    assert CompetitionEth.epoch_cnt() == 15
    
    with ape.reverts():
        USDT.approve(CompetitionEth.address, 6000000000, sender=Deployer)
        receipt = CompetitionEth.send_reward(1000000000, 6, sender=Deployer)

    assert CompetitionEth.epoch_info(1).competition_start == 1716249600
    assert CompetitionEth.epoch_info(1).competition_end == 1716336000

    assert CompetitionEth.epoch_info(2).competition_start == 1716336000
    assert CompetitionEth.epoch_info(2).competition_end == 1716422400

    func_sig = function_signature(
        "set_winner_list((address,uint256)[])")
    # enc_abi = encode(["(address,uint256)[]"], [[(Deployer.address, 1000000000)]])
    enc_abi = encode(["(address,uint256)[]"], [[]])
    add_payload = encode(["bytes32"], [b'123456'])
    payload = func_sig + enc_abi + add_payload
    with ape.reverts():
        CompetitionEth.set_winner_list([], sender=Compass)
    CompetitionEth(sender=Compass, data=payload)
    assert CompetitionEth.active_epoch_num() == 2

    assert CompetitionEth.epoch_info(2).prize_amount == 3000000000

    balance = USDT.balanceOf(CompetitionEth.address)
    CompetitionEth.emergency_withdraw(balance, sender=Admin)
    
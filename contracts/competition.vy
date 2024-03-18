#pragma version 0.3.10
#pragma optimize gas
#pragma evm-version shanghai
"""
@title      ETH price prediction competition for Juice Bot
@license    Apache 2.0
@author     Volume.finance
"""
struct BidInfo:
    sender: address
    pricePredictionVal: uint256

struct WinnerInfo:
    winner: address
    claimableAmount: uint256
    claimStatus: bool

competitionStart: public(uint256)
competitionEnd: public(uint256)
admin: public(address)
rewardToken: public(address)
bidInfo: public(HashMap[uint256, BidInfo])
winnerInfo: public(HashMap[uint256, WinnerInfo])
epochCnt: public(uint256)
entryCnt: public(uint256)

MAX_ENTRY: constant(uint256) = 1000

interface ERC20:
    def approve(_spender: address, _value: uint256) -> bool: nonpayable
    def transfer(_to: address, _value: uint256) -> bool: nonpayable
    def transferFrom(_from: address, _to: address, _value: uint256) -> bool: nonpayable

@external
def __init__(_admin: address, _rewardToken: address):
    self.admin = _admin
    self.rewardToken = _rewardToken
    self.epochCnt = 0
    self.entryCnt = 0

@external
def setAdmin(_newAdmin: address):
    assert msg.sender == self.admin
    
    self.admin = _newAdmin

@external
def setRewardToken(_newRewardToken: address):
    assert msg.sender == self.admin
    
    self.rewardToken = _newRewardToken

@external
def sendReward(_amount: uint256):
    # Check that sender is admin
    assert msg.sender == self.admin
    assert ERC20(self.rewardToken).transferFrom(msg.sender, self, _amount, default_return_value=True), "Transaction Failed"
    
    self.competitionStart = block.timestamp / 86400 * 86400 + 86400
    self.competitionEnd = block.timestamp / 86400 * 86400 + 86400 * 2
    self.epochCnt += 1

@external
def bid(_pricePredictionVal: uint256):
    assert block.timestamp >= self.competitionStart
    assert block.timestamp < self.competitionEnd
    assert self.entryCnt < MAX_ENTRY

    self.bidInfo[self.epochCnt] = BidInfo({
        sender: msg.sender,
        pricePredictionVal: _pricePredictionVal
    })
    self.entryCnt += 1

@external
def setWinnerList(_epochCnt: uint256, _winnerInfo: WinnerInfo):
    assert msg.sender == self.admin

    self.winnerInfo[_epochCnt] = _winnerInfo

@external
@payable
def __default__():
    pass
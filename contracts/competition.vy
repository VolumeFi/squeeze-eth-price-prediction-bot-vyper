#pragma version 0.3.10
#pragma optimize gas
#pragma evm-version shanghai
"""
@title      ETH price prediction competition for Juice Bot
@license    Apache 2.0
@author     Volume.finance
"""
struct EpochInfo:
    competitionStart: uint256
    competitionEnd: uint256
    entryCnt: uint256

struct BidInfo:
    sender: address
    pricePredictionVal: uint256

struct WinnerInfo:
    winner: address
    claimableAmount: uint256

struct SwapInfo:
    route: address[11]
    swap_params: uint256[5][5]
    amount: uint256
    expected: uint256
    pools: address[5]

MAX_ENTRY: constant(uint256) = 1000
MAX_SIZE: constant(uint256) = 8

admin: public(address)
rewardToken: public(address)
FACTORY: immutable(address)
bidInfo: public(HashMap[uint256, HashMap[uint256, BidInfo]])
winnerInfo: public(HashMap[uint256, HashMap[uint256, WinnerInfo]])
epochInfo: public(HashMap[uint256, EpochInfo])
epochCnt: public(uint256)
activeEpochNum: public(uint256)
claimableAmount: public(HashMap[address, uint256])

interface ERC20:
    def approve(_spender: address, _value: uint256) -> bool: nonpayable
    def transfer(_to: address, _value: uint256) -> bool: nonpayable
    def transferFrom(_from: address, _to: address, _value: uint256) -> bool: nonpayable

interface CreateBotFactory:
    def create_bot(
        swap_infos: DynArray[SwapInfo, MAX_SIZE], 
        collateral: address, 
        settlement: address, 
        debt: uint256, 
        N: uint256, 
        callbacker: address, 
        callback_args: DynArray[uint256, 5], 
        leverage: uint256, 
        deleverage_percentage: uint256, 
        health_threshold: uint256, 
        profit_taking: uint256, 
        expire: uint256, 
        number_trades: uint256, 
        interval: uint256,
        delegate: address = msg.sender
    ): payable

event RewardSent:
    epochId: uint256
    sender: address
    rewardToken: address
    amount: uint256
    competitionStart: uint256
    competitionEnd: uint256

event Bid:
    epochId: uint256
    bidder: address
    predictionVal: uint256

@external
def __init__(_admin: address, _rewardToken: address, _factory: address):
    self.admin = _admin
    self.rewardToken = _rewardToken
    FACTORY = _factory
    self.epochCnt = 0
    self.activeEpochNum = 0

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

    # Transfer reward token to the contract
    _rewardToken: address = self.rewardToken
    assert ERC20(_rewardToken).transferFrom(msg.sender, self, _amount, default_return_value=True), "Transaction Failed"
    
    _epochCnt: uint256 = self.epochCnt
    _competitionStart: uint256 = 0
    _competitionEnd: uint256 = 0

    if _epochCnt == 0:
        _epochCnt += 1
        self.activeEpochNum += 1

        _competitionStart = block.timestamp / 86400 * 86400 + 86400
        _competitionEnd = block.timestamp / 86400 * 86400 + 86400 * 2

    else:
        _lastEpochInfo: EpochInfo = self.epochInfo[_epochCnt]
        _lastCompetitionStart: uint256 = _lastEpochInfo.competitionStart
        _lastCompetitionEnd: uint256 = _lastEpochInfo.competitionEnd
        
        _epochCnt += 1
        if block.timestamp >= _lastCompetitionStart:
            _competitionStart = block.timestamp / 86400 * 86400 + 86400
            _competitionEnd = block.timestamp / 86400 * 86400 + 86400 * 2
        elif block.timestamp < _lastCompetitionStart:
            _competitionStart = _lastCompetitionStart + 86400
            _competitionEnd = _lastCompetitionEnd + 86400

    # Write
    self.epochInfo[_epochCnt] = EpochInfo({
        competitionStart: _competitionStart,
        competitionEnd: _competitionEnd,
        entryCnt: 0
    })    
    self.epochCnt = _epochCnt

    # Event Log
    log RewardSent(_epochCnt, msg.sender, _rewardToken, _amount, _competitionStart, _competitionEnd)

@external
def bid(_pricePredictionVal: uint256):
    _activeEpochNum: uint256 = self.activeEpochNum
    _epochInfo: EpochInfo = self.epochInfo[_activeEpochNum]
    assert _activeEpochNum <= self.epochCnt
    assert block.timestamp >= _epochInfo.competitionStart
    assert block.timestamp < _epochInfo.competitionEnd
    assert _epochInfo.entryCnt < MAX_ENTRY

    _epochInfo.entryCnt += 1
    
    #Write
    self.bidInfo[_activeEpochNum][_epochInfo.entryCnt] = BidInfo({
        sender: msg.sender,
        pricePredictionVal: _pricePredictionVal
    })
    self.epochInfo[_activeEpochNum] = _epochInfo

    # Event Log
    log Bid(_activeEpochNum, msg.sender, _pricePredictionVal)

# need to confirm with team
@external
def setWinnerList(_winnerInfos: DynArray[WinnerInfo, MAX_ENTRY]):
    assert msg.sender == self.admin

    _activeEpochNum: uint256 = self.activeEpochNum
    assert _activeEpochNum <= self.epochCnt

    _i: uint256 = 0
    for _winnerInfo in _winnerInfos:
        self.winnerInfo[_activeEpochNum][_i] = _winnerInfos[_i]
        self.claimableAmount[_winnerInfo.winner] += _winnerInfo.claimableAmount

        _i += 1

    # increse activeEpochNum for activating the next Epoch
    _activeEpochNum += 1
    self.activeEpochNum = _activeEpochNum

@external
@payable
def createBot(swap_infos: DynArray[SwapInfo, MAX_SIZE], 
        collateral: address, 
        settlement: address, 
        debt: uint256, 
        N: uint256, 
        callbacker: address, 
        callback_args: DynArray[uint256, 5], 
        leverage: uint256, 
        deleverage_percentage: uint256, 
        health_threshold: uint256, 
        profit_taking: uint256, 
        expire: uint256, 
        number_trades: uint256, 
        interval: uint256):
    assert self.claimableAmount[msg.sender] > 0

    CreateBotFactory(FACTORY).create_bot(
        swap_infos, 
        collateral, 
        settlement, 
        debt, 
        N, 
        callbacker, 
        callback_args, 
        leverage, 
        deleverage_percentage, 
        health_threshold,
        profit_taking,
        expire,
        number_trades,
        interval, 
        msg.sender)

@external
@payable
def __default__():
    pass
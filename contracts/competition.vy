#pragma version 0.3.10
#pragma optimize gas
#pragma evm-version shanghai
"""
@title      ETH price prediction competition for Juice Bot
@license    Apache 2.0
@author     Volume.finance
"""
struct EpochInfo:
    competition_start: uint256
    competition_end: uint256
    entry_cnt: uint256

struct BidInfo:
    sender: address
    price_prediction_val: uint256

struct WinnerInfo:
    winner: address
    claimable_amount: uint256

struct SwapInfo:
    route: address[11]
    swap_params: uint256[5][5]
    amount: uint256
    expected: uint256
    pools: address[5]

MAX_ENTRY: constant(uint256) = 1000
MAX_SIZE: constant(uint256) = 8
DAY_IN_SEC: constant(uint256) = 86400

FACTORY: public(immutable(address))

admin: public(address)
reward_token: public(address)
bid_info: public(HashMap[uint256, HashMap[uint256, BidInfo]])
winner_info: public(HashMap[uint256, HashMap[uint256, WinnerInfo]])
epoch_info: public(HashMap[uint256, EpochInfo])
epoch_cnt: public(uint256)
active_epoch_num: public(uint256)
claimable_amount: public(HashMap[address, uint256])

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
    epoch_id: uint256
    sender: address
    reward_token: address
    amount: uint256
    competition_start: uint256
    competition_end: uint256

event Bid:
    epoch_id: uint256
    bidder: address
    prediction_val: uint256

@external
def __init__(_admin: address, _reward_token: address, _factory: address):
    self.admin = _admin
    self.reward_token = _reward_token
    FACTORY = _factory

# Check that sender is admin
@internal
def _check_admin():
    assert msg.sender == self.admin, "Not Admin"

@external
def set_admin(_new_admin: address):
    self._check_admin()
    self.admin = _new_admin

@external
def set_reward_token(_new_reward_token: address):
    self._check_admin()
    self.reward_token = _new_reward_token

@external
def send_reward(_amount: uint256):
    self._check_admin()

    # Transfer reward token to the contract
    _reward_token: address = self.reward_token
    assert ERC20(_reward_token).transferFrom(msg.sender, self, _amount, default_return_value=True), "Send Reward Failed"
    
    _epoch_cnt: uint256 = self.epoch_cnt
    _competition_start: uint256 = 0
    _competition_end: uint256 = 0

    if _epoch_cnt == 0:
        _epoch_cnt = unsafe_add(_epoch_cnt, 1)
        self.active_epoch_num = unsafe_add(self.active_epoch_num, 1)

        _competition_start = unsafe_add(unsafe_mul(unsafe_div(block.timestamp, DAY_IN_SEC), DAY_IN_SEC), DAY_IN_SEC)
        _competition_end = unsafe_add(_competition_start, DAY_IN_SEC)

    else:
        _last_epoch_info: EpochInfo = self.epoch_info[_epoch_cnt]
        _last_competition_start: uint256 = _last_epoch_info.competition_start
        _last_competition_end: uint256 = _last_epoch_info.competition_end
        
        _epoch_cnt = unsafe_add(_epoch_cnt, 1)
        if block.timestamp >= _last_competition_start:
            _competition_start = unsafe_add(unsafe_mul(unsafe_div(block.timestamp, DAY_IN_SEC), DAY_IN_SEC), DAY_IN_SEC)
            _competition_end = unsafe_add(_competition_start, DAY_IN_SEC)
        elif block.timestamp < _last_competition_start:
            _competition_start = unsafe_add(_last_competition_start, DAY_IN_SEC)
            _competition_end = unsafe_add(_last_competition_end, DAY_IN_SEC)

    # Write
    self.epoch_info[_epoch_cnt] = EpochInfo({
        competition_start: _competition_start,
        competition_end: _competition_end,
        entry_cnt: 0
    })    
    self.epoch_cnt = _epoch_cnt

    # Event Log
    log RewardSent(_epoch_cnt, msg.sender, _reward_token, _amount, _competition_start, _competition_end)

@external
def bid(_price_prediction_val: uint256):
    _active_epoch_num: uint256 = self.active_epoch_num
    _epoch_info: EpochInfo = self.epoch_info[_active_epoch_num]
    
    assert _active_epoch_num <= self.epoch_cnt, "No Reward yet"
    assert block.timestamp >= _epoch_info.competition_start, "Not Active"
    assert block.timestamp < _epoch_info.competition_end, "Not Active"
    assert _epoch_info.entry_cnt < MAX_ENTRY, "Entry Limited"

    _epoch_info.entry_cnt = unsafe_add(_epoch_info.entry_cnt, 1)
    
    #Write
    self.bid_info[_active_epoch_num][_epoch_info.entry_cnt] = BidInfo({
        sender: msg.sender,
        price_prediction_val: _price_prediction_val
    })
    self.epoch_info[_active_epoch_num] = _epoch_info

    # Event Log
    log Bid(_active_epoch_num, msg.sender, _price_prediction_val)

# need to confirm with team
@external
def set_winner_list(_winner_infos: DynArray[WinnerInfo, MAX_ENTRY]):
    self._check_admin()

    _active_epoch_num: uint256 = self.active_epoch_num
    assert _active_epoch_num <= self.epoch_cnt, "No Reward yet"

    _i: uint256 = 0
    for _winner_info in _winner_infos:
        self.winner_info[_active_epoch_num][_i] = _winner_infos[_i]
        self.claimable_amount[_winner_info.winner] = unsafe_add(self.claimable_amount[_winner_info.winner], _winner_info.claimable_amount)
        _i = unsafe_add(_i, 1)

    # increse activeEpochNum for activating the next Epoch
    self.active_epoch_num = unsafe_add(_active_epoch_num, 1)

@external
@payable
def create_bot(swap_infos: DynArray[SwapInfo, MAX_SIZE], 
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

    _claimable_amount: uint256 = self.claimable_amount[msg.sender]
    assert _claimable_amount > 0, "No Claimable Amount"

    ERC20(self.reward_token).approve(self, _claimable_amount)
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

    # init claimable amount 
    self.claimable_amount[msg.sender] = 0

@external
@payable
def __default__():
    pass
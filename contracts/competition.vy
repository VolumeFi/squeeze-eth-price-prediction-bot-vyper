#pragma version 0.3.10
#pragma optimize gas
#pragma evm-version shanghai
"""
@title      Eth price prediction competition for Juice Bot
@license    Apache 2.0
@author     Volume.finance
"""

interface ERC20:
    def approve(_spender: address, _value: uint256) -> bool: nonpayable
    def transfer(_to: address, _value: uint256) -> bool: nonpayable
    def transferFrom(_from: address, _to: address, _value: uint256) -> bool: nonpayable

@external
@payable
def __default__():
    pass
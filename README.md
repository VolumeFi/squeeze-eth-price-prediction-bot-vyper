# Eth price prediction competition bot for marketing Juice Bot

The contracts are written in Vyper.

## Competition Contract (`competition.vy`)

### Functions (=== old one : !!! need to be updated !!! ===)
#### `set_admin`

- **Parameters:**
  - `_new_admin` (address): New admin address

#### `set_reward_token`

- **Parameters:**
  - `_new_reward_token` (address): New reward token address

#### `send_reward`

- **Parameters:**
  - `_amount` (uint256): Reward token amount

#### `bid`

- **Parameters:**
  - `_price_prediction_val` (uint256):

#### `set_winner_list`

- **Parameters:**
  - `_winner_infos` (DynArray[WinnerInfo, MAX_ENTRY]):

#### `create_bot`
Creates a new bot with specified parameters.

- **Parameters:**
  - `swap_infos` (DynArray[SwapInfo, MAX_SIZE]): Array of SwapInfo to define the swap strategy.
  - `collateral` (address): Address of the collateral token.
  - `debt` (uint256): Amount of crvUSD to be borrowed.
  - `N` (uint256): Number of bands for the Curve pool deposit.
  - `callbacker` (address): Address of the callback contract.
  - `callback_args` (DynArray[uint256,5]): Additional arguments for the callback.
  - `leverage` (unt256):
  - `deleverage_percentage` (uint256):
  - `health_threshold` (uint256):
  - `profit_taking` (uint256):
  - `expire` (uint256): Expiration timestamp of the bot.
  - `number_trades` (uint256):
  - `interval` (uint256):
  

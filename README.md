# Eth price prediction competition bot for marketing Juice Bot
Volume is looking to set up an ETH price prediction competition sweepstakes. The goal is to help users get familiar with juice bot. The rewards will come from Volumes marketing budget.

Each epoch: start at 00:00 UTC, submission ends at 23:59 UTC on the same day, results are published at 23:59 UTC the following day

- We fund the contract with 5 days of rewards of $5,000 USDC on ETH network, each week (Competition runs Tuesday - Saturday each week.)
- User predict ETH price on ARB network.
- We have to spend 1 tx on ETH to provide the ARB winners list into the ETH vyper contract, each day.
- Usre spends to create bot and claim reward for bot on ETH.

The contracts are written in Vyper. 
REF(https://www.notion.so/volumefi/EPIC-03-08-24-Juice-Bot-Price-Prediction-Competition-Sweepstakes-d014fa9bccca4715a9fb051bb9873371)

## Competition Eth Contract (`competitionEth.vy`)

#### `update_compass`
Updates the Compass-EVM address.

- **Parameters:**
  - `_new_compass` (address): New Compass-EVM address.

#### `set_paloma`
Sets the Paloma CW address.

#### `set_reward_token`
Sets the reward token address.

- **Parameters:**
  - `_new_reward_token` (address): New reward token address.
  - `_new_decimals` (uint256): New reward token's decimals.

#### `send_reward`
Send Reward token to the smart contract and start the Epoch.

- **Parameters:**
  - `_amount`: (uint256): Reward token amount.

#### `set_winner_list`
Set the winners list of current active epoch.

- **Parameters:**
  - _winner_infos: (DynArray[WinnerInfo, MAX_ENTRY]): Array of WinnerInfo to define the winner addresses and claimable amounts.

#### `create_bot`
Creates a new bot with specified parameters.
(REF) https://github.com/VolumeFi/Curve-healthy-juice-degen-vyper/blob/master/README.md

## Competition Arb Contract (`competitionArb.vy`)

#### `update_compass`
Updates the Compass-EVM address.

- **Parameters:**
  - `_new_compass` (address): New Compass-EVM address.

#### `set_paloma`
Sets the Paloma CW address.

#### `set_active_epoch`
Sets the active epoch information. (epoch id, competition start and end timestamp)

- **Parameters:**
  - `_epoch_info` (EpochInfo): EpochInfo to define the active epoch id and competition start, end timestamp

#### `bid`
Predicts the ETH price value. 

- **Parameters:**
  - `_price_prediction_val` (uint256): ETH price prediction value in wei.

## Events (`competitionEth.vy`)

#### `RewardSent`
Emitted when a reward is sented.

- **Properties:**
  - `epoch_id` (uint256):
  - `sender` (address):
  - `reward_token` (address):
  - `amount` (uint256):
  - `competition_start` (uint256):

#### `UpdateCompass`
Emitted when the Compass-EVM address is updated.

- **Properties:**
  - `old_compass` (address): The old Compass-EVM address.
  - `new_compass` (address): The new Compass-EVM address.

#### `UpdateRewardToken`
Emitted when the reward token address is updated.

- **Properties:**
  - `new_reward` (address): The new reward token address.
  - `new_decimals` (uint256): The new reward token's decimals.

#### `SetPaloma`
Emitted when the Paloma CW address is set.

- **Properties:**
  - `paloma` (bytes32): The Paloma CW address.

#### `SetWinner`
Emitted when the winner is set with claimable amount.

- **Properties:**
  - `epoch_id` (uint256): Epoch id
  - `winner` (address): Winner's address.
  - `claimable_amount` (uint256): Claimable amount for the winner.

#### `Claimed`
Emitted when the sender create the juice bot by using his claimable amount.

- **Properties:**
  - `sender` (address): Sender's address
  - `claimable_amount` (uint256): Claimable amount.
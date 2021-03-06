# Vuzec-Contracts

[![Twitter Follow](https://img.shields.io/twitter/follow/vuzecmx?style=social)](https://twitter.com/vuzecmx)

### Live Demo: [Vuzec.com](https://vuzec.com/)

# Vuzec:

Vuzec platform tries to solve the problem exist in the Music Industry of Labels cutting huge percentage of the revenue by providing a safe way for fans to fund the artists and trading the Albums generating revenue for artist and fans. The platform helps Artist monitize their album through selling the share of album to artist as NFTs and also trade them for USDC in the Dex.

## Some Terminologies:

- ### ALM Tokens:

  ALM tokens are the ERC-1155 standard Album Tokens created by the artists. They are used by the artists to raise funds for their project initially through the presale of the ALM NFTs.

  Every ALM have default of 1 million supply for a token and the number going in the presale is decided by the Artist themselves. Artist or any fans holding the ALM can provide liquidity by providing the USDC and ALM token pool.

- ### WALM:

  Wrapped ALM or WALM is the equivalent ERC-20 of ALM NFT with the total supply as of ALM NFTs. They are used as the tokens in the liquidity pool along with USDC. WALM tokens are Minted and Burned as the user wants during swap and liquidity pool action. They are never ended in any of the user wallets and remains just in the pool.

## Vuzec Dex:

Vuzec uses the UniswapV2 protocol for Dex creation. Uniswap is a decentralized exchange for the ERC-20 tokens. Vuzec Dex enables the trading of ERC-1155 NFT's by the help of WALM tokens.

ALM tokens are sent to the WALM contract that mints the equvalent number of ERC-20 to the router contract which is added to the pool during Swapping and Liquidity providing. On removal of the Liquidity and Swapping the ERC-20 is sent to the WALM contract that returns back the ERC-1155 to the user back. The ERC-20 tokens are minted and burned in the procedure and doesn't end to any of the wallet address.

# Uniswap Router Interfaces:

## `addLiquidityALMandUSDC`

Adds Liquidity of ALM and USDC for existing pool or create the liquidity of ALM and USDC for non existing pools.

**Parameters**

|        | Name                | Type      | Description                                 |
| ------ | ------------------- | --------- | ------------------------------------------- |
| @param | `USDC`              | `address` | Address of USDC token.                      |
| @param | `WALM`              | `address` | Address of WALM for the ALM token.          |
| @param | `idOfALM`           | `uint`    | Id of the ALM token.                        |
| @param | `amountUSDCDesired` | `uint`    | Amount of desired ALM.                      |
| @param | `amountUSDCMin`     | `uint`    | Amount of minimum USDC need to be added.    |
| @param | `amountALMMin`      | `uint`    | Amount of minimum ALM need to be added.     |
| @param | `to`                | `address` | Address of Liquidity Provider.              |
| @param | `deadline`          | `uint`    | Deadline of transaction in Unix Epoch time. |

**Returns**

- `amountUSDC` - Amount of USDC added to the pool.
- `amountALM` - Amount of ALM added to the pool
- `liquidity`- Amount of liquidity share of the Liquidity Provider.

## `removeLiquidityUSDCandALM`

Removes the Liquidity.

**Parameters**

|        | Name                | Type      | Description                                 |
| ------ | ------------------- | --------- | ------------------------------------------- |
| @param | `USDC`              | `address` | Address of USDC token.                      |
| @param | `WALM`              | `address` | Address of WALM for the ALM token.          |
| @param | `idOfALM`           | `uint`    | Id of the ALM token.                        |
| @param | `amountUSDCDesired` | `uint`    | Amount of desired ALM.                      |
| @param | `amountUSDCMin`     | `uint`    | Amount of minimum USDC need to be removed.  |
| @param | `amountALMMin`      | `uint`    | Amount of minimum ALM need to be removed.   |
| @param | `to`                | `address` | Address of receiver.                        |
| @param | `deadline`          | `uint`    | Deadline of transaction in Unix Epoch time. |

**Returns**

- `amountUSDC` - Amount of USDC removed to the pool.
- `amountALM` - Amount of ALM removed to the pool
- `liquidity`- Amount of liquidity share of the Liquidity Provider.

## `swapExactALMforUSDC`

Swap AML for USDC.

**Parameters**

|        | Name           | Type         | Description                                 |
| ------ | -------------- | ------------ | ------------------------------------------- |
| @param | `amountOutMin` | `uint`       | Amount of minimum USDC.                     |
| @param | `path`         | `address[] ` | Path of address to follow .                 |
| @param | `to`           | `address`    | Adress of sender.                           |
| @param | `deadline`     | `uint`       | Deadline of transaction in Unix Epoch time. |
| @param | `idOfALM`      | `uint`       | Id of ALM token.                            |
| @param | `WALM`         | `address`    | Address of WALM.                            |
| @param | `amountIn`     | `uint`       | Amount of ALM sended.                       |

**Returns**

- `amounts` - Amounts received.

## `swapExactUSDCForALM`

Swap USDC for ALM.

**Parameters**

|        | Name           | Type         | Description                                 |
| ------ | -------------- | ------------ | ------------------------------------------- |
| @param | `amountIn`     | `uint`       | Amount of USDC to sent.                     |
| @param | `amountOutMin` | `uint`       | Amount of minimum ALM to receive.           |
| @param | `path`         | `address[] ` | Path of address to follow .                 |
| @param | `to`           | `address`    | Adress of sender.                           |
| @param | `deadline`     | `uint`       | Deadline of transaction in Unix Epoch time. |
| @param | `idOfALM`      | `uint`       | Id of ALM token.                            |
| @param | `WALM`         | `address`    | Address of WALM.                            |

**Returns**

- `amounts` - Amounts received.

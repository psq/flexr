# flexr
A reimplementation of the Ampleforth token and its geyser

Like Ampleforth, flexr adjusts its supply based on current demand.  If the price is lower than the target price, the supply contracts, and in the same fashion, if the price has increased too much, the supply will expand.  For long time holders, the daily planned rebase does not affect the amount they own, i.e. holding 2 token worth $1 or holding 1 token worth $2, or 4 tokens worth $0.5 does not change how much your tokens are worth.  It does provide an opportunity for short term traders to arbitrage the price around the rebase time.

To minimize price movement, the rebase is done with a planned 30 days to reach the target price, but with no memory of what was done before, so each rebase adjusts the supply by 1/30 of what is needed.

By using an elastic supply, it minimizes the possibility of demand/supply shocks, and creates an asset with near zero correlation to other assets.  In other words, this reduces [systematic risk](https://www.ampleforth.org/economics/)

### Economic background on flexible synthetic commodities
See the [paper](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=2000118) on Synthetic Commodity Money by George Selgin.

Abstract
> This paper considers reform possibilities posed by a type of base money that has heretofore been overlooked in the literature on monetary economics. I call this sort of money "synthetic" commodity money because it shares features with both commodity money and fiat money, as these are usually defined, without fitting the conventional definition of either; examples of such money are Bitcoin and the "Swiss dinars" that served as the currency of northern Iraq for over a decade. I argue that the attributes of synthetic commodity money are such as might supply the basis for a monetary regime that does not require oversight by any monetary authority, yet is capable of providing for all such changes in the money stock as may be needed to achieve a high degree of macroeconomic stability.


### More on Ampleforth
The Ampleforth [whitepaper](https://www.ampleforth.org/papers/)

Abstract
> Synthetic commodities, such as Bitcoin, have thus far demonstrated low correlation with stocks, currencies, and precious metals. However, today’s synthetics are also highly correlated with each other and with Bitcoin. The natural question to ask is: can a synthetic commodity have low correlation with both Bitcoin and traditional asset groups? In this paper, we 1) introduce Ampleforth: a new synthetic commodity and 2) suggest that the Ampleforth protocol, detailed below, will produce a step-function-like volatility fingerprint that is distinct from existing synthetics.

### Why non correlation is important
TBD


### Example

TBD: add table with price and balance variations

# The flexr ecosystem

The [flexr token](#the-flexr-token) implements the [SRC20 trait](#the-src20-token-trait) relies on a new version of [swapr](#changes-to-swapr) for trading.  Liquidity providers on [swapr](#changes-to-swapr) can in turn stake their liquidity using a new swapr pair token on the [flexr geyser](#the-flexr-geyser).  The longer you stake your liquidity token, the higher the reward you may get (in [flexr](#the-flexr-token) token), up to 3x after 2 months.  The [flexr token](#the-flexr-token#) relies on an [Oracle](#the-flexr-oracle) to learn about the price average over the past 24 hours to know whether, or how much to [rebase](#flexr-rebase-math).


## the SRC20 token trait
swapr relied on tokens that implements the [SRC20 trait](./contracts/src20-trait.clar) to allow for:
- transfer
- name of the token
- getting the balance of an owner
- getting the total supply

## Changes to swapr
The original version of [swapr](https://github.com/psq/swapr) was relased for the first Blockstak Hackaton.
- balances are no longer hardcoded, allowing for tokens with an elastic supply
- the main swaprs contract can be used for multiple pairs by leveraging traits
- liquidity provider now get a token for their share of liquidity they provide to a pair, allowing them to exchange it, or stake it (used by flexr's geyser!)

## The flexr token

### flexr rebase math
During a rebase, everyone's balances get adjusted.  As this would not scale very well with a high number of holders, rebase calculate an adjustment factor to apply to apply to each balance, which gets finalized when exchanging the flexr token.

## The flexr Oracle
see https://docs.pro.coinbase.com/#oracle for details on how to do it, but still missing secp256k1 signature verification (https://github.com/blockstack/stacks-blockchain/issues/1134)

## The flexr geyser
Liquidity providers on swapr get a token representing their share of the liquity they provide on the flexr-wrapr pair (STX needs to be wrapped )

## Putting it all together
(see more details in the [Scenario descrition](./scenario.md)) or the [tests](./test/unit/flexr.ts)


# Gotchas
To run the tests requires a patched version of the clarity-native-bin module to support setting STX balances from [balances.json](./balances.json)
See https://github.com/blockstack/clarity-js-sdk/issues/77 for more details.  The real fix will need a bit more work than what was used



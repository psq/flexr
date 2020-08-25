# flexr
A reimplementation of the [Ampleforth](https://www.ampleforth.org/) Token, Oracle and [Geyser](https://www.ampleforth.org/dapps/).

This also demonstrates how multiple Clarity contracts can interact with each other to provide value to users.  The sum is greater than the parts!

## TL;DR
[flexr](#the-flexr-token) is an [SRC20 token](#the-src20-token-trait) with an elastic supply, guaranteed by design to be [uncorrelated](#why-non-correlation-is-important) to other tokens.  The supply of flexr token gets adjusted ([rebased](#flexr-rebase-math)) on a daily basis based on the price provided by an [Oracle](#the-flexr-oracle).  The flexr token can be exchanged with STX on [swapr](#changes-to-swapr).  Liquidity providers on swapr are further incentivized by staking the proof they provide liquity on a [Geyser](#changes-to-swapr) that provides higher and higher rewards the longer liquidity providers keep staking.

## Introduction

Like Ampleforth (AMPL), flexr adjusts its supply based on current demand.  If the price is lower than the target price, the supply contracts, and in the same fashion, if the price has increased too much, the supply will expand.  For long time holders, the daily planned rebase does not affect the amount they own, i.e. holding 2 token worth $1 or holding 1 token worth $2, or 4 tokens worth $0.5 does not change how much your tokens are worth.  It does provide an opportunity for short term traders to arbitrage the price around the rebase time, and do so at a [profit](https://gauntlet.network/reports/ampleforth).

To minimize price movement, the rebase is done with a planned 30 days to reach the target price, with no memory of what was done before, so each rebase adjusts the supply by 1/30 of what is needed based on all available data at the time the rebase occurs.

Using an elastic supply minimizes the possibility of demand/supply shocks, and creates an asset with near zero correlation to other assets.  In other words, this reduces [systematic risk](https://www.ampleforth.org/economics/)

### Economic background on flexible synthetic commodities
See the [paper](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=2000118) on Synthetic Commodity Money by George Selgin.

Abstract
> This paper considers reform possibilities posed by a type of base money that has heretofore been overlooked in the literature on monetary economics. I call this sort of money "synthetic" commodity money because it shares features with both commodity money and fiat money, as these are usually defined, without fitting the conventional definition of either; examples of such money are Bitcoin and the "Swiss dinars" that served as the currency of northern Iraq for over a decade. I argue that the attributes of synthetic commodity money are such as might supply the basis for a monetary regime that does not require oversight by any monetary authority, yet is capable of providing for all such changes in the money stock as may be needed to achieve a high degree of macroeconomic stability.


### More on Ampleforth
The Ampleforth [whitepaper](https://www.ampleforth.org/papers/)

Abstract
> Synthetic commodities, such as Bitcoin, have thus far demonstrated low correlation with stocks, currencies, and precious metals. However, today’s synthetics are also highly correlated with each other and with Bitcoin. The natural question to ask is: can a synthetic commodity have low correlation with both Bitcoin and traditional asset groups? In this paper, we 1) introduce Ampleforth: a new synthetic commodity and 2) suggest that the Ampleforth protocol, detailed below, will produce a step-function-like volatility fingerprint that is distinct from existing synthetics.

### Why non correlation is important
Uncorrelated return streams is the holy grail of portfolio construction, both greatly reducing drawdowns (because one asset zigs when other zags), but potentially providing a total return greater than the average of the weighted returns (because your money has to work less hards as you did not lose as much, i.e. if you lose 50%, you need a gain of 100% to break even).

### Example

Supply, price and balances over time:
|  | market cap| total supply    |price | alice adjusted balance | alice adjusted share | bob adjusted balance | bob adjusted share | supply∆     | supply∆ / smoothing |
|--|-----------|-----------|------|------------------|----------------|------------------|----------------|--------------|-------------|
|1 | 1,300,000 | 1,000,000 |1.30  | 100,000      | 10.000%        |                  |                |   300,000 | 10,000 |
|2 | 1,111,000 | 1,010,000 |1.10  | 101,000      | 10.000%        |                  |                |   101,000 | 3,366  |
|3 | 912,030   | 1,013,366 |0.90  | 101,336      | 10.000%        | 50,000.0         | 4.934%         |  -101336  | -3,377 | 
|4 | 1,009,988 | 1,009,988 |1     | 100,998      | 10.000%        | 49,833.3         | 4.934%         |  0        | 0      |
|5 | 1,211,986 | 1,009,988 |1.2   | 100,998      | 10.000%        | 49,833.3         | 4.934%         |  201,997  | 6,733  |  
|6 | 1,118,394 | 1,016,722 |1.1   | 101,672      | 10.000%        | 50,165.6         | 4.934%         | 101,672   | 3,389  | 

Bob gets 100,000 flexr at t=1 with an adjustment factor of 1,000,000 (the supply at t=1), and Alice gets 50,000 flexr with an ajdustment factor of 1,013,366.667 (the supply at t=3 when she gets her tokens).  See below for more on the [adjustement factor](#flexr-rebase-math).

Note #1: Alice and Bob share remains constant despite the balance and price adjustments.  This is the invariant maintained by the rebase.

Note #2: there is no price change at t=4, so no rebase needed.

# The flexr ecosystem

The [flexr token](#the-flexr-token) implements the [SRC20 trait](#the-src20-token-trait) and relies on a new version of [swapr](#changes-to-swapr) for trading.  Liquidity providers on [swapr](#changes-to-swapr) can in turn stake their liquidity using a new swapr pair token on the [flexr geyser](#the-flexr-geyser).  The longer you stake your liquidity token, the higher the reward you may get (in [flexr](#the-flexr-token) token), up to 3x after 2 weeks (subject to change, as it will likely be longer).  The [flexr token](#the-flexr-token) relies on an [Oracle](#the-flexr-oracle) to learn about the price average over the past 24 hours to know whether, and how much to [rebase](#flexr-rebase-math).

By incentivizing liquidity providers, the Ampleforth token was able to become the pair (AMPL-ETH) with the most liquidity on Uniswap in just a few months.  Having a similar incentive should help the flexr token in a similar way.


## The SRC20 token trait
swapr now relies on tokens that implements the [SRC20 trait](./contracts/src20-trait.clar) to allow for:
- transfer
```closure
(define-public (transfer (recipient principal) (amount uint)) ...)
```
- name of the token
```closure
(define-public (name) ...)
```
- getting the balance of an owner
```closure
(define-public (balance-of (recipient principal)) ...)
```
- getting the total supply
```closure
(define-public (total-supply) ...)
```

SRC20, or Stacks Request for Comments #20 (to keep things simple, as most people understand what [ERC20](https://eips.ethereum.org/EIPS/eip-20) is), although it would be desirable to creat a new SIP so tokens are interoperable on the Stacks chain.  SRC20 does not requires the same set of methods ERC20 does.

## Changes to swapr
The original version of [swapr](https://github.com/psq/swapr) was relased for the first Blockstak Hackaton.

In order to support flexr, it was necessary to introduce the following changes:
- balances are no longer hardcoded, allowing for tokens with an elastic supply.  It looks like Uniswap v2 can also support this as it supports AMPL.
- the main swapr contract can be used for multiple pairs by leveraging [Clarity Traits](https://docs.blockstack.org/references/clarity-language#dynamic-dispatch), although it is very likely that the final version will need one contract deployed per pair anyway, but this can be the exact same contract, not a contract with hardcoded pair addresses, so a net benefit.
- liquidity providers now receive a [token](./contracts/swapr-token-flexr-wrapr.clar) for their share of liquidity they provide to a pair, allowing them to exchange it with others, or stake it (used by flexr's [geyser](#the-flexr-geyser)!).  Uniswap v2 supports this as well.  That token itself is also an [SRC20 token](#the-src20-token-trait) with an additional function `mint` only callable by the `swapr` contract when a user adds to their liquidity position).

Note: technically, the new version of swapr is not part of this Hackaton submission, but shows how various contracts can leverage contracts for a rich ecosystem.  The changes, though, are fairly significant.

## The flexr token

The flexr token implements the functions in the [SRC20 trait](#the-src20-token-trait) with the addition of a `rebase` function:
```
(define-public (rebase) ...)
```

### flexr rebase math
During a rebase, everyone's balances get adjusted.  As this would not scale very well with a high number of holders, rebase calculate an adjustment factor to apply to each balance, which gets finalized when exchanging the flexr token.  `balance-of` also reflects that adjustment.

```
supply∆ = (current_price - price_target) * current_total_supply / price_target
smoothed_supply∆ = supply∆ / 30
``` 

Anyone can trigger a rebase, as long as it is past the previous rebase window (about 24 hours), so there is no reliance on an admin to do so.  You just pay the minimal transaction fee.

## The flexr Oracle
As Clarity does not yet support secp256k1 signature verification (see https://github.com/blockstack/stacks-blockchain/issues/1134, coming up shortly!), it is using a dumb oracle where a trusted party can supply the volume weighted average price for the previous period.  That price has to be provided within a small time period before the rebase can be triggered.

Ultimately, once the support for signature verification is added, the need for an Oracle contract will be removed, and a model like the [Coinbase Oracle](https://docs.pro.coinbase.com/#oracle) can be used by passing a signed price data payload to the [rebase](#flexr-rebase-math) function.  The signed payload contains the price and the timestamp, making it secure.  Again, removing the need for a trusted third party to update the oracle.  Decentralization FTW!  Multiple such oracles could be added.

To avoid rebasing too often and introduce unnecessary noise, a rebase will be triggered only if the price has deviated more than 5% lower or higher than the target price (not fully implemented at the moment).

## The flexr Geyser
Liquidity providers on swapr get a token representing their share of the liquity they provide on the flexr-wrapr pair (STX needs to be wrapped to provide an SRC20 equivalent token).  Not only do liquitity providers benefit by earning a fee on all swaps, they also benefit by staking their liquity token in exchange for higher and higher rewards the longer they stake their tokens.

The base reward is calculated as follow:
```
reward = amount * reward-factor * #blocks / reward-period per 1000 swapr-flexr-wrapr token in flexr tokens
reward-factor is 1 for first 1000 blocks (about 1 week)
reward-factor is 2 for next 1000 blocks (about 2 weeks)
reward-factor is 3 for anything longer than 2000 blocks (> 2 weeks)
```

The reward gets credited when the user unstakes their liquidity provider tokens (i.e. they gets their liquity token back, and their flexr reward).

Most likely, the reward periods will be longer (months) to encourage long term holding.

## Putting it all together
For more details, see a testing scenario [Scenario description](./scenario.md) or the [tests](./test/unit/flexr.ts) that implement that scenario.  As Clarity JS SDK still does not support setting STX balances, this requires a special version of the Clarity JS SDK.  Fortunately, `clarity-bin` supports providing a [json](./balances.json) file.


# Gotchas
### Gotcha #1
To run the tests requires an up to date version of the clarity-native-bin module to support setting STX balances from [balances.json](./balances.json) and a patched version of the clarity js sdk.

See https://github.com/blockstack/clarity-js-sdk/issues/77 for more details.  The real fix will need a bit more work than what was used to provide a more developer friendly experience.  Happy to provide this patch to anyone, it is only a couple lines.

### Gotcha #2
The flexr token can not use the native `ft-token` provided by Clarity, as the `ft-token` does not support dynamically changing the balance as required by the flexr monetary policy.  

This means, however that you lose the safety provided by the post conditions on token transfers.  In fact, it would require new types of post conditions (check variable value, check map values, ...), which could be also helpful in other cases.

### Gotcha #3
The flexr token relies on `block-height` for defining the rebase window (144 blocks to be exact, which represents about 24 hours with a 10 minutes block average).  

However, as the Clarity JS SDK does not allow for advancing to any block, that value has been artificially reduced (to 3).  Having a function to advance to a given block would be highly beneficial to test these kind of use cases that are supposed to be long running (weeks to months, so 1000s of blocks)




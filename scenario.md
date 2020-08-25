# Test scenario
- initialize all [contracts](./contracts).  There are 2 traits, and 6 contracts interacting with each order.  The order in which you deploy them is important!
- init flexr treasury with [flexr](./contracts/flexr-token.clar) tokens (see line before last) and enough [stx](./balances.json) for funding swapr 
- setup flexr-wrapr pair in swapr and fund from flexr treasury (as STX is not a token, `wrapr` is used to wrap STX into an [SRC20 token](./contracts/src20-trait.clar) that can be used with `swapr`)
- fund Geyser from flexr treasury (done when deploying the [flexr](./contracts/flexr-token.clar) contract, see last line)

- fund user[1-3] with [stx](./balances.json) 
- user[1-3] wrap stx using `wrapr`
- user[1-3] buy flexr tokens
- user1 provide liquidity to the flexr-stx pair and gets back liquidity token
- user1 stakes his flexr-stx pair in the geyser

- go through a few price updates and rebase (how to advance block faster with clarity-js-sdk?)
- user3 tries rebase arbitrage (TBD)

- user1 withdraws reward from geyser and checks earnings
- user1 withdraw liquity and checks earnings (TBD)

# Scenario run output
```
initialize balances.json /var/folders/10/vfzc9gqn6cs8d2zldp6v83400000gp/T/blockstack-local-1598255557-djwmpi.db
    Check contracts
      ✓ should have a valid syntax (19272ms)
    Full scenario
======>  wrap.treasury
======>  createPair.treasury
======>  wrap.alice
======>  swapExactYforX.alice
======>  addToPosition.alice
======>  stake.alice
======>  wrap.bob
======>  wrap.zoe
======>  wrap.zoe
======>  swapExactYforX.bob - round 0
======>  swapExactYforX.bob
======>  swapExactXforY.zoe
======>  updatePrice.zoe
======>  rebase.zoe - 1100000
======>  swapExactYforX.bob - round 1
======>  swapExactYforX.bob
======>  swapExactXforY.zoe
======>  updatePrice.zoe
======>  rebase.zoe - 1150000
======>  swapExactYforX.bob - round 2
======>  swapExactYforX.bob
======>  swapExactXforY.zoe
======>  updatePrice.zoe
======>  rebase.zoe - 1050000
======>  swapExactYforX.bob - round 3
======>  swapExactYforX.bob
======>  swapExactXforY.zoe
======>  updatePrice.zoe
======>  rebase.zoe - 950000
======>  swapExactYforX.bob - round 4
======>  swapExactYforX.bob
======>  swapExactXforY.zoe
======>  updatePrice.zoe
======>  rebase.zoe - 900000
======>  unstake.alice
      ✓ check balances after running scenario (206ms)


  2 passing (24s)

✨  Done in 24.57s.
```

Alice got 960_000 micro flexr after just a few blocks 😂

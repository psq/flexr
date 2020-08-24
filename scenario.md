# Intro
Intro on Ampleforth and its geyser, and how it uses Uniswap
the benefit of non correlation
synthetic commodity (with elasticity)
Intro on changes to swapr

# Test scenario
- init contracts
- init flexr treasury with flexr and enough stx for funding swapr
- setup flexr-stx pair in swapr and fund from flexr treasury
- fund geyser from flexr treasury

- fund user[1-3] with stx
- user[1-3] wrap stx
- user[1-3] buy flexr
- user1 provide liquidity to the flexr-stx pair
- user1 stakes his flexr-stx pair in the geyser

- go through a few price updates and rebase (how to advance block faster with clarity-js-sdk?)
x user3 tries rebase arbitrage

- user1 withdraws reward from geyser and checks earnings
x user1 withdraw liquity and checks earnings 

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

# Conclusion
Challenges
- advance block to any block
- initial balances using clarity js sdk (hack)
- support for token with varying balance, can not use `ft-token`, would require new post conditions (check variable value, check map values, ...)

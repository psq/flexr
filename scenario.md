# Intro
Intro on Ampleforth and its geyser, and how it uses Uniswap
the benefit of non correlation
synthetic commodity (with elasticity)
Intro on changes to swapr

# Test scenario
- init contracts
- init flexr treasury with flexr and enough stx for funding swapr
. setup flexr-stx pair in swapr and fund from flexr treasury
- fund geyser from flexr treasury

fund user[1-3] with stx
user[1-3] buy flexr
user[1-2] provide liquidity to the flexr-stx pair
user1 stakes his flexr-stx pair in the geyser

go through a few price updates and rebase (how to advance block faster with clarity-js-sdk?)
user3 tries rebase arbitrage

user1 withdraws reward from geyser and checks earnings
user2 withdraw liquity and checks earnings 
user3 checks earnings

# Conclusion
Challenge


## TODOs
create/update clients
setup STX balances (or use a fake token)
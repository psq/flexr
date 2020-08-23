# flexr
A reimplementation of the Ampleforth token and geyser

Economic background on flexible synthetic commodities https://papers.ssrn.com/sol3/papers.cfm?abstract_id=2000118

Abstract
> This paper considers reform possibilities posed by a type of base money that has heretofore been overlooked in the literature on monetary economics. I call this sort of money "synthetic" commodity money because it shares features with both commodity money and fiat money, as these are usually defined, without fitting the conventional definition of either; examples of such money are Bitcoin and the "Swiss dinars" that served as the currency of northern Iraq for over a decade. I argue that the attributes of synthetic commodity money are such as might supply the basis for a monetary regime that does not require oversight by any monetary authority, yet is capable of providing for all such changes in the money stock as may be needed to achieve a high degree of macroeconomic stability.




The Ampleforth whitepaper https://www.ampleforth.org/papers/

Abstract
> Synthetic commodities, such as Bitcoin, have thus far demonstrated low correlation with stocks, currencies, and precious metals. However, today’s synthetics are also highly correlated with each other and with Bitcoin. The natural question to ask is: can a synthetic commodity have low correlation with both Bitcoin and traditional asset groups? In this paper, we 1) introduce Ampleforth: a new synthetic commodity and 2) suggest that the Ampleforth protocol, detailed below, will produce a step-function-like volatility fingerprint that is distinct from existing synthetics.




Caveat: running with custom clarity module that seeds based on https://github.com/blockstack/clarity-js-sdk/issues/77 so that it loads `balances.json` from the root of this project

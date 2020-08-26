import { Client, Provider, ProviderRegistry, Result } from "@blockstack/clarity"
import { readFileSync } from 'fs'

const chai = require('chai')
chai.use(require('chai-string'))
const assert = chai.assert

import { FlexrClient } from "../../src/clients/flexr-client"
import { GeyserClient } from "../../src/clients/geyser-client"
import { OracleClient } from "../../src/clients/oracle-client"
import { SwaprClient } from "../../src/clients/swapr-client"
import { SwaprTokenClient } from "../../src/clients/swapr-token-client"
import { StxClient } from "../../src/clients/stx-client"
import {
  NoLiquidityError,
  NotOKErr,
  NotOwnerError,
  TransferError,
} from '../../src/errors'

describe("full test suite", () => {
  let provider: Provider

  let src20TraitClient: Client
  let swaprTraitClient: Client

  let flexrClient: Client
  let geyserClient: Client
  let oracleClient: Client
  let swaprClient: Client
  let swaprTokenClient: Client
  let stxClient: Client

  const prices = [
    1_100_000,
    1_150_000,
    1_050_000,
      950_000,
      900_000,
    1_000_000,
    1_000_000,
    1_000_000,
  ]

  const addresses = [
    "SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7",  // alice, u20 tokens of each
    "S02J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKPVKG2CE",  // bob, u10 tokens of each
    "SZ2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKQ9H6DPR",  // zoe, no tokens
    "SP138CBPVKYBQQ480EZXJQK89HCHY32XBQ0T4BCCD",  // TBD
    "SP1EHFWKXQEQD7TW9WWRGSGJFJ52XNGN6MTJ7X462",  // flexr treasury
    "SP30JX68J79SMTTN0D2KXQAJBFVYY56BZJEYS3X0B",  // TBD

  ]
  const alice = addresses[0]
  const bob = addresses[1]
  const zoe = addresses[2]
  const flexr_treasury = `${addresses[4]}`
  const flexr_token = `S1G2081040G2081040G2081040G208105NK8PE5.flexr-token`
  const swapr_token = `S1G2081040G2081040G2081040G208105NK8PE5.swapr-token`
  const stx_token = `S1G2081040G2081040G2081040G208105NK8PE5.stx-token`

  before(async () => {
    provider = await ProviderRegistry.createProvider()

    src20TraitClient = new Client("S1G2081040G2081040G2081040G208105NK8PE5.src20-trait", "src20-trait", provider)
    swaprTraitClient = new Client("S1G2081040G2081040G2081040G208105NK8PE5.swapr-trait", "swapr-trait", provider)

    flexrClient = new FlexrClient("S1G2081040G2081040G2081040G208105NK8PE5", provider)
    geyserClient = new GeyserClient("S1G2081040G2081040G2081040G208105NK8PE5", provider)
    oracleClient = new OracleClient("S1G2081040G2081040G2081040G208105NK8PE5", provider)
    swaprClient = new SwaprClient("S1G2081040G2081040G2081040G208105NK8PE5", provider)
    swaprTokenClient = new SwaprTokenClient("flexr-stx", "S1G2081040G2081040G2081040G208105NK8PE5", provider)
    stxClient = new StxClient("S1G2081040G2081040G2081040G208105NK8PE5", provider)
  })

  describe("Check contracts", () => {
    it("should have a valid syntax", async () => {
      await src20TraitClient.checkContract()
      await src20TraitClient.deployContract() // deploy first

      await swaprTraitClient.checkContract()
      await swaprTraitClient.deployContract() // deploy first

      await swaprClient.checkContract()
      await swaprClient.deployContract()

      await stxClient.checkContract()
      await stxClient.deployContract()

      await oracleClient.checkContract()
      await oracleClient.deployContract()

      await flexrClient.checkContract()
      await flexrClient.deployContract()

      await swaprTokenClient.checkContract()
      await swaprTokenClient.deployContract() // deploy second

      await geyserClient.checkContract()
      await geyserClient.deployContract()
    })
  })

  describe("Full scenario", () => {
    before(async () => {
      // // wrap stx into wrapr
      // console.log("======>  wrap.treasury")
      // assert(await wraprClient.wrap(50_000_000_000_000, {sender: flexr_treasury}))

      // create flerx-swapr pair
      console.log("======>  createPair.treasury")
      assert(await swaprClient.createPair(flexr_token, stx_token, swapr_token, "flexr-stx", 50_000_000_000_000, 50_000_000_000_000, {sender: flexr_treasury}), "createPair did not return true")


      // // Alice wraps STX
      // console.log("======>  wrap.alice")
      // assert(await wraprClient.wrap(100_000_000_000, {sender: alice}))
      // Alice gets some FLEXR
      console.log("======>  swapExactYforX.alice")
      assert(await swaprClient.swapYforExactX(flexr_token, stx_token, 40_000_000_000, {sender: alice}))
      // Alice add a position on swapr's flexr-stx pair
      console.log("======>  addToPosition.alice")
      assert(await swaprClient.addToPosition(flexr_token, stx_token, swapr_token, 40_000_000_000, 40_000_000_000, {sender: alice}), "addToPosition did not return true")
      // Alice stakes her position on geyser
      console.log("======>  stake.alice")
      assert(await geyserClient.stake(40_000_000_000, {sender: alice}), "stake did not return true")

      // // Bob wraps STX
      // console.log("======>  wrap.bob")
      // assert(await wraprClient.wrap(50_000_000_000, {sender: bob}))

      // // Zoe wraps STX
      // console.log("======>  wrap.zoe")
      // assert(await wraprClient.wrap(50_000_000_000, {sender: zoe}))
      // Zoe gets a lot of FLEXR
      console.log("======>  swapExactYforX.zoe")
      assert(await swaprClient.swapExactYforX(flexr_token, stx_token, 50_000_000_000, {sender: zoe}))

      for (let i = 0; i < 5; i++) {
        console.log(`======>  swapExactYforX.bob - round ${i}`)

        // Bob exhanges stx for flexr (back and forth 5x)
        console.log("======>  swapExactYforX.bob")
        assert(await swaprClient.swapExactYforX(flexr_token, stx_token, 2_000_000_000, {sender: bob}))
        // Zoe exhanges flexr for stx (back and forth 5x)
        console.log("======>  swapExactXforY.zoe")
        assert(await swaprClient.swapExactXforY(flexr_token, stx_token, 2_000_000_000, {sender: zoe}))

        console.log("======>  updatePrice.zoe")
        assert(await oracleClient.updatePrice(prices[i], {sender: zoe}))
        console.log(`======>  rebase.zoe - ${prices[i]}`)
        assert(await flexrClient.rebase({sender: zoe}))
      }

      // Alice collects her reward on geyser
      console.log("======>  unstake.alice")
      assert(await geyserClient.unstake({sender: alice}), "stake did not return true")
    })

    it("check balances after running scenario", async () => {
      // Alice checks the fees she collected
      assert.equal(await flexrClient.balanceOf(alice, {sender: alice}), 880_000)

      // total FLEXR supply
      assert.equal(await flexrClient.totalSupply({sender: alice}), 1_014_873_127_537_500) // starting value: 1_000_000_000_000_000
    })

  })

  after(async () => {
    await provider.close()
  })
})

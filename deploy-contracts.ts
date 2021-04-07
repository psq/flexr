const BigNum = require("bn.js")
import * as fs from "fs"
const fetch = require("node-fetch")
import {
  broadcastTransaction,
  makeContractDeploy,
  TxBroadcastResultOk,
  TxBroadcastResultRejected,
} from "@stacks/transactions"
import { StacksTestnet, StacksMainnet } from '@stacks/network'


const keys = JSON.parse(
  fs.readFileSync("./keychain.json").toString()
)

console.log("keys", keys)
const mode = process.argv[2] || 'mocknet'

console.log("deploying swapr with", keys.swapr.stacksAddress, "on", mode)

const STACKS_API_URL = mode === 'mocknet' ? 'http://localhost:3999' : mode === 'nanorails' ? 'https://stacks-api.nanorails.com' : 'https://stacks-node-api.mainnet.stacks.co'
const network = mode === 'mainnet' ? new StacksMainnet() : new StacksTestnet()
network.coreApiUrl = STACKS_API_URL
console.log("using", STACKS_API_URL)

async function deployContract(contract_name: string, fee: number) {
  console.log(`deploying ${contract_name}`)
  const codeBody = fs.readFileSync(`./contracts/${contract_name}.clar`).toString()

  const transaction = await makeContractDeploy({
    contractName: contract_name,
    codeBody,
    senderKey: keys.swapr.privateKey,
    network,
  })

  const result = await broadcastTransaction(transaction, network)
  if ((result as TxBroadcastResultRejected).error) {
    if (
      (result as TxBroadcastResultRejected).reason === "ContractAlreadyExists"
    ) {
      console.log(`${contract_name} already deployed`)
      return "" as TxBroadcastResultOk
    } else {
      throw new Error(
        `failed to deploy ${contract_name}: ${JSON.stringify(result)}`
      )
    }
  }
  const processed = await processing(result as TxBroadcastResultOk)
  if (!processed) {
    throw new Error(`failed to deploy ${contract_name}: transaction not found`)
  }
  return result as TxBroadcastResultOk
}

function timeout(ms: number) {
  return new Promise((resolve) => setTimeout(resolve, ms))
}

async function processing(tx: String, count: number = 0): Promise<boolean> {
  console.log("processing", tx, count)
  var result = await fetch(
    `${STACKS_API_URL}/extended/v1/tx/${tx}`
  )
  var value = await result.json()
  if (value.tx_status === "success") {
    console.log(`transaction ${tx} processed`)
    // console.log(value)
    return true
  }
  // if (value.tx_status === "pending") {
  //   console.log("pending" /*, value*/)
  // }
  if (count > 10) {
    console.log("failed after 2 attempts", value)
    return false
  }

  await timeout(15000)
  return processing(tx, count + 1)
}

(async () => {
  await deployContract('src20-trait', 3000)
  await deployContract('plaid-token', 3000)
  await deployContract('swapr-trait', 3000)
  await deployContract('swapr', 3000)
  await deployContract('stx-token', 3000)
  await deployContract('oracle', 3000)
  await deployContract('flexr-token', 3000)
  await deployContract('flexr-stx-token', 3000)
  await deployContract('plaid-stx-token', 3000)
  await deployContract('geyser', 3000)


  // create flexr-stx pair
  // create plaid-stx pair

})()

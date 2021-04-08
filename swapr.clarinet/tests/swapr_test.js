
import { Clarinet, Tx, types } from 'https://deno.land/x/clarinet@v0.3.0/index.ts'
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts'
import { unwrapTuple, parse } from './utils.js'

Clarinet.test({
  name: "Ensure that <...> - swapr",
  async fn(chain, accounts) {
    // console.log("types", types)
    let block = chain.mineBlock([

        // (define-public (create-pair (token-x-trait <src20-token>) (token-y-trait <src20-token>) (token-swapr-trait <swapr-token>) (pair-name (string-ascii 32)) (x uint) (y uint))
        // Tx.contractCall("counter", "increment", [types.uint(1)], accounts[0].address),


      Tx.contractCall('swapr', 'create-pair', [
        types.principal('ST000000000000000000002AMW42H.plaid-token'),
        types.principal('ST000000000000000000002AMW42H.stx-token'),
        types.principal('ST000000000000000000002AMW42H.plaid-stx-token'),
        types.ascii('plaid-stx-token'),
        types.uint(10000000),
        types.uint(10000000),
      ], accounts[0].address)

    ])
    // console.log("receipts", JSON.stringify(block.receipts, null, 2))
    assertEquals(block.receipts.length, 1)
    assertEquals(block.height, 2)

    console.log("get-pair-count", JSON.stringify(chain.callReadOnlyFn("swapr", "get-pair-count", [], accounts[0].address), null, 2))
    const result = chain.callReadOnlyFn("swapr", "get-pair-contracts", [types.uint(1)], accounts[0].address).result

    console.log("get-pair-contracts", JSON.stringify(result, null, 2))
    console.log(unwrapTuple(parse(result)))

    block = chain.mineBlock([
      /*
       * Add transactions with:
       * Tx.contractCall(...)
      */
    ])
    assertEquals(block.receipts.length, 0)
    assertEquals(block.height, 3)
  },
})

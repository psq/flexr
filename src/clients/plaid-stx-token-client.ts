import { Client, Provider, Receipt, Result } from '@blockstack/clarity'
import {
  TransferError,
} from '../errors'

import {
  parse,
  unwrapXYList,
  unwrapSome,
  unwrapOK,
} from '../utils'

export class PlaidStxTokenClient extends Client {
  token_name: string

  constructor(name: string, principal: string, provider: Provider) {
    super(
      `${principal}.plaid-stx-token`,
      'plaid-stx-token',
      provider
    )
    this.token_name = name
  }

  async transfer(recipient: string, amount: number, params: { sender: string }): Promise<boolean> {
    const tx = this.createTransaction({
      method: { name: "transfer", args: [`'${recipient}`, `u${amount}`] }
    })
    await tx.sign(params.sender)
    const receipt = await this.submitTransaction(tx)
    if (receipt.success) {
      // console.log("debugOutput", receipt.debugOutput)
      const result = Result.unwrap(receipt)
      return result.startsWith('Transaction executed and committed. Returned: true')
    }
    throw TransferError
  }

  async balanceOf(owner: string): Promise<number> {
    const query = this.createQuery({
      method: {
        name: 'balance-of',
        args: [`'${owner}`],
      },
    })
    const receipt = await this.submitQuery(query)
    console.log("balanceOf.receipt", receipt)
    return Result.unwrapUInt(receipt)
  }


}

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

export class OracleClient extends Client {
  token_name: string

  constructor(principal: string, provider: Provider) {
    super(
      `${principal}.oracle`,
      'oracle',
      provider
    )
  }

  async updatePrice(price: number, params: { sender: string }): Promise<boolean> {
    const tx = this.createTransaction({
      method: { name: "update-price", args: [`u${price}`] }
    })
    await tx.sign(params.sender)
    const receipt = await this.submitTransaction(tx)
    if (receipt.success) {
      // console.log("updatePrice.debugOutput", receipt.debugOutput)
      const result = Result.unwrap(receipt)
      return result.startsWith('Transaction executed and committed. Returned: true')
    }
    console.log("updatePrice", receipt)
    throw TransferError
  }

  // async balanceOf(owner: string): Promise<number> {
  //   const query = this.createQuery({
  //     method: {
  //       name: 'balance-of',
  //       args: [`'${owner}`],
  //     },
  //   })
  //   const receipt = await this.submitQuery(query)
  //   return Result.unwrapUInt(receipt)
  // }


}

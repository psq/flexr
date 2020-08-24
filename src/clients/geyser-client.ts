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

export class GeyserClient extends Client {
  token_name: string

  constructor(principal: string, provider: Provider) {
    super(
      `${principal}.geyser`,
      'geyser',
      provider
    )
  }

  async stake(amount: number, params: { sender: string }): Promise<boolean> {
    const tx = this.createTransaction({
      method: { name: "stake", args: [`u${amount}`] }
    })
    await tx.sign(params.sender)
    const receipt = await this.submitTransaction(tx)
    if (receipt.success) {
      console.log("debugOutput", receipt.debugOutput)
      const result = Result.unwrap(receipt)
      return result.startsWith('Transaction executed and committed. Returned: true')
    }
    console.log("stake", receipt)
    throw TransferError
  }

  async unstake(params: { sender: string }): Promise<boolean> {
    const tx = this.createTransaction({
      method: { name: "unstake", args: [] }
    })
    await tx.sign(params.sender)
    const receipt = await this.submitTransaction(tx)
    if (receipt.success) {
      console.log("debugOutput", receipt.debugOutput)
      const result = Result.unwrap(receipt)
      return result.startsWith('Transaction executed and committed. Returned: true')
    }
    console.log("unstake", receipt)
    throw TransferError
  }

  async totalSupply(owner: string): Promise<number> {
    const query = this.createQuery({
      method: {
        name: 'total-supply',
        args: [],
      },
    })
    const receipt = await this.submitQuery(query)
    return Result.unwrapUInt(receipt)
  }


}

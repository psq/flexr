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

export class WraprClient extends Client {
  constructor(principal: string, provider: Provider) {
    super(
      `${principal}.wrapr-token`,
      'wrapr-token',
      provider
    )
  }

  async wrap(amount: number, params: { sender: string }): Promise<boolean> {
    const tx = this.createTransaction({
      method: { name: "wrap", args: [`u${amount}`] }
    });
    await tx.sign(params.sender)
    const receipt = await this.submitTransaction(tx)
    if (receipt.success) {
      // console.log("wrap", receipt.debugOutput)
      const result = Result.unwrap(receipt)
      // console.log("result", result)
      return result.startsWith('Transaction executed and committed')
    }
    throw new TransferError()
  }

  async unwrap(amount: number, params: { sender: string }): Promise<boolean> {
    const tx = this.createTransaction({
      method: { name: "unwrap", args: [`u${amount}`] }
    })
    await tx.sign(params.sender)
    const receipt = await this.submitTransaction(tx)
    if (receipt.success) {
      // console.log("debugOutput", receipt.debugOutput)
      const result = Result.unwrap(receipt)
      return result.startsWith('Transaction executed and committed. Returned: true')
    }
    throw new TransferError()
  }

  async transfer(recipient: string, amount: number, params: { sender: string }): Promise<boolean> {
    const tx = this.createTransaction({
      method: { name: "transfer", args: [`'${recipient}`, `u${amount}`] }
    })
    await tx.sign(params.sender)
    const receipt = await this.submitTransaction(tx)
    // console.log(receipt)
    if (receipt.success) {
      // console.log("debugOutput", receipt.debugOutput)
      const result = Result.unwrap(receipt)
      return result.startsWith('Transaction executed and committed. Returned: true')
    }
    throw new TransferError()
  }

  async balanceOf(owner: string): Promise<number> {
    const query = this.createQuery({
      method: {
        name: 'balance-of',
        args: [`'${owner}`],
      },
    })
    const receipt = await this.submitQuery(query)
    console.log("receipt", receipt)
    return Result.unwrapUInt(receipt)
  }

  async totalSupply(): Promise<number> {
    const query = this.createQuery({
      method: {
        name: 'total-supply',
        args: [],
      },
    })
    const receipt = await this.submitQuery(query)
    console.log("receipt", receipt)
    return Result.unwrapUInt(receipt)
  }

}

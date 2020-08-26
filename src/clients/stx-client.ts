import { Client, Provider, Receipt, Result } from '@blockstack/clarity'
import {
  TransferError,
} from '../errors'

export class StxClient extends Client {
  constructor(principal: string, provider: Provider) {
    super(
      `${principal}.stx-token`,
      'stx-token',
      provider
    )
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

  async name(): Promise<number> {
    const query = this.createQuery({
      method: {
        name: 'name',
        args: [],
      },
    })
    const receipt = await this.submitQuery(query)
    console.log("receipt", receipt)
    return Result.unwrap(receipt)
  }

}

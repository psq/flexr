import { Client, Provider, Receipt, Result } from '@blockstack/clarity'
import {
  ClarityParseError,
  NoLiquidityError,
  NotOwnerError,
  NotOKErr,
  NotSomeErr,
} from '../errors'

import {
  parse,
  unwrapXYList,
  unwrapSome,
  unwrapOK,
} from '../utils'

export class SwaprClient extends Client {
  constructor(principal: string, provider: Provider) {
    super(
      `${principal}.swapr`,
      'swapr',
      provider
    )
  }

  async createPair(token_x_token: string, token_y_token: string, swapr_token: string, name: string, x: number, y: number, params: { sender: string }): Promise<boolean> {
    // console.log("createPair.args", [`${token_x_token}`, `${token_y_token}`, `${swapr_token}`, `"${name}"`, `u${x}`, `u${y}`])
    const tx = this.createTransaction({
      method: { name: "create-pair", args: [`'${token_x_token}`, `'${token_y_token}`, `'${swapr_token}`, `"${name}"`, `u${x}`, `u${y}`] }
    })
    await tx.sign(params.sender)
    const receipt = await this.submitTransaction(tx)
    if (receipt.success) {
      // console.log("createPair", receipt.debugOutput)
      const result = Result.unwrap(receipt)
      // console.log("createPair.result", result)
      return result.startsWith('Transaction executed and committed. Returned: true')
    }
    console.log("createPair failure", receipt)
    throw NotOKErr 
  }

  async addToPosition(token_x_token: string, token_y_token: string, swapr_token: string, x: number, y: number, params: { sender: string }): Promise<boolean> {
    const tx = this.createTransaction({
      method: { name: "add-to-position", args: [`'${token_x_token}`, `'${token_y_token}`, `'${swapr_token}`, `u${x}`, `u${y}`] }
    })
    await tx.sign(params.sender)
    const receipt = await this.submitTransaction(tx)
    if (receipt.success) {
      console.log(receipt.debugOutput)
      const result = Result.unwrap(receipt)
      return result.startsWith('Transaction executed and committed. Returned: true')
    }
    console.log("addToPosition failure", receipt)
    throw NotOKErr
    
  }

  async reducePosition(token_x_token: string, token_y_token: string, swapr_token: string, percent: number, params: { sender: string }): Promise<Object> {
    const tx = this.createTransaction({
      method: { name: "reduce-position", args: [`'${token_x_token}`, `'${token_y_token}`, `'${swapr_token}`, `u${percent}`] }
    })
    await tx.sign(params.sender)
    const receipt = await this.submitTransaction(tx)
    // console.log("debugOutput", receipt.debugOutput)
    const result = Result.unwrap(receipt)

    if (result.startsWith('Transaction executed and committed. Returned: ')) {
      const start_of_list = result.substring('Transaction executed and committed. Returned: '.length)  // keep a word so unwrapXYList will behave like it was with 'ok'
      const parsed = parse(start_of_list.substring(0, start_of_list.indexOf(')') + 1))
      return unwrapXYList(parsed)
    }
    throw new NotOKErr()
  }

  async swapExactXforY(token_x_token: string, token_y_token: string, dx: number, params: { sender: string }): Promise<Object> {
    const tx = this.createTransaction({
      method: { name: "swap-exact-x-for-y", args: [`'${token_x_token}`, `'${token_y_token}`, `u${dx}`] }
    })
    await tx.sign(params.sender)
    const receipt = await this.submitTransaction(tx)
    // console.log("debugOutput", receipt.debugOutput)
    const result = Result.unwrap(receipt)

    if (result.startsWith('Transaction executed and committed. Returned: ')) {
      const start_of_list = result.substring('Transaction executed and committed. Returned: '.length)  // keep a word so unwrapXYList will behave like it was with 'ok'
      const parsed = parse(start_of_list.substring(0, start_of_list.indexOf(')') + 1))
      return unwrapXYList(parsed)
    }
    throw new NotOKErr()
  }

  async swapXforExactY(token_x_token: string, token_y_token: string, dy: number, params: { sender: string }): Promise<Object> {
    const tx = this.createTransaction({
      method: { name: "swap-x-for-exact-y", args: [`'${token_x_token}`, `'${token_y_token}`, `u${dy}`] }
    })
    await tx.sign(params.sender)
    const receipt = await this.submitTransaction(tx)
    // console.log("debugOutput", receipt.debugOutput)
    const result = Result.unwrap(receipt)

    if (result.startsWith('Transaction executed and committed. Returned: ')) {
      const start_of_list = result.substring('Transaction executed and committed. Returned: '.length)  // keep a word so unwrapXYList will behave like it was with 'ok'
      const parsed = parse(start_of_list.substring(0, start_of_list.indexOf(')') + 1))
      return unwrapXYList(parsed)
    }
    throw new NotOKErr()
  }

  async swapExactYforX(token_x_token: string, token_y_token: string, dy: number, params: { sender: string }): Promise<Object> {
    const tx = this.createTransaction({
      method: { name: "swap-exact-y-for-x", args: [`'${token_x_token}`, `'${token_y_token}`, `u${dy}`] }
    })
    await tx.sign(params.sender)
    const receipt = await this.submitTransaction(tx)
    // console.log("debugOutput", receipt.debugOutput)
    const result = Result.unwrap(receipt)

    if (result.startsWith('Transaction executed and committed. Returned: ')) {
      const start_of_list = result.substring('Transaction executed and committed. Returned: '.length)  // keep a word so unwrapXYList will behave like it was with 'ok'
      const parsed = parse(start_of_list.substring(0, start_of_list.indexOf(')') + 1))
      return unwrapXYList(parsed)
    }
    throw new NotOKErr()
  }

  async swapYforExactX(token_x_token: string, token_y_token: string, dx: number, params: { sender: string }): Promise<Object> {
    const tx = this.createTransaction({
      method: { name: "swap-y-for-exact-x", args: [`'${token_x_token}`, `'${token_y_token}`, `u${dx}`] }
    })
    await tx.sign(params.sender)
    const receipt = await this.submitTransaction(tx)
    // console.log("debugOutput", receipt.debugOutput)
    const result = Result.unwrap(receipt)

    if (result.startsWith('Transaction executed and committed. Returned: ')) {
      const start_of_list = result.substring('Transaction executed and committed. Returned: '.length)  // keep a word so unwrapXYList will behave like it was with 'ok'
      const parsed = parse(start_of_list.substring(0, start_of_list.indexOf(')') + 1))
      return unwrapXYList(parsed)
    }
    throw new NotOKErr()
  }

  async positionOf(token_x_token: string, token_y_token: string, owner: string): Promise<number> {
    const query = this.createQuery({
      method: {
        name: 'get-position-of',
        args: [`'${token_x_token}`, `'${token_y_token}`, `'${owner}`],
      },
    })
    const receipt = await this.submitQuery(query)
    return Result.unwrapUInt(receipt)
  }

  async balances(): Promise<Object> {
    const query = this.createQuery({
      method: {
        name: 'get-balances',
        args: [`'${token_x_token}`, `'${token_y_token}`],
      },
    })
    const receipt = await this.submitQuery(query)
    return unwrapXYList(unwrapOK(parse(Result.unwrap(receipt))))
  }

  async positions(): Promise<number> {
    const query = this.createQuery({
      method: {
        name: 'get-positions',
        args: [],
      },
    })
    const receipt = await this.submitQuery(query)
    return Result.unwrapUInt(receipt)
  }

  async balancesOf(owner: string): Promise<Object> {
    const query = this.createQuery({
      method: {
        name: 'get-balances-of',
        args: [`'${owner}`],
      },
    })
    const receipt = await this.submitQuery(query)
    // console.log("balancesOf", receipt)
    const result = Result.unwrap(receipt)
    if (result.startsWith('(err')) {
      throw new NoLiquidityError()
    } else {
      return unwrapXYList(unwrapOK(parse(result)))
    }
  }

  async setFeeTo(address: string, params: { sender: string }): Promise<boolean> {
    const tx = this.createTransaction({
      method: { name: "set-fee-to-address", args: [`'${address}`] }
    })
    await tx.sign(params.sender)
    const receipt = await this.submitTransaction(tx)
    // console.log("receipt", receipt)
    // console.log("debugOutput", receipt.debugOutput)
    if (receipt.success) {
      const result = Result.unwrap(receipt)
      // console.log("result", result)
      if (result.startsWith('Transaction executed and committed. Returned: ')) {
        const start = result.substring('Transaction executed and committed. Returned: '.length)
        const extracted = start.substring(0, start.indexOf('\n'))
        // console.log("extracted", `=${extracted}=`)
        if (extracted === 'true') {
          return true
        }
      }
    }
    throw new NotOwnerError()
  }

  async resetFeeTo(params: { sender: string }): Promise<boolean> {
    const tx = this.createTransaction({
      method: { name: "reset-fee-to-address", args: [] }
    })
    await tx.sign(params.sender)
    const receipt = await this.submitTransaction(tx)
    // console.log("receipt", receipt)
    // console.log("debugOutput", receipt.debugOutput)
    if (receipt.success) {
      const result = Result.unwrap(receipt)
      // console.log("result", result)
      if (result.startsWith('Transaction executed and committed. Returned: ')) {
        const start = result.substring('Transaction executed and committed. Returned: '.length)
        const extracted = start.substring(0, start.indexOf('\n'))
        // console.log("extracted", `=${extracted}=`)
        if (extracted === 'true') {
          return true
        }
      }
    }
    throw new NotOwnerError()
  }

  async collectFees(params: { sender: string }): Promise<Object> {
    const tx = this.createTransaction({
      method: { name: "collect-fees", args: [] }
    })
    await tx.sign(params.sender)
    const receipt = await this.submitTransaction(tx)
    // console.log("receipt", receipt)
    console.log("debugOutput", receipt.debugOutput)
    if (receipt.success) {
      const result = Result.unwrap(receipt)
      // console.log("result", result)
      if (result.startsWith('Transaction executed and committed. Returned: ')) {
        const start_of_list = result.substring('Transaction executed and committed. Returned: '.length)  // keep a word so unwrapXYList will behave like it was with 'ok'
        const parsed = parse(start_of_list.substring(0, start_of_list.indexOf(')') + 1))
        return unwrapXYList(parsed)
      }
    }
    throw new NotOwnerError()
  }

  async getFeeTo(): Promise<string | null> {
    const query = this.createQuery({
      atChaintip: true,
      method: { name: "get-fee-to-address", args: [] }
    })
    const result = await this.submitQuery(query)
    // console.log("getFeeTo", Result.unwrap(result))
    const value = unwrapOK(parse(Result.unwrap(result)))
    return (value === 'none' ? null : unwrapSome(value))
  }

  async fees(): Promise<Object> {
    const query = this.createQuery({
      method: {
        name: 'get-fees',
        args: [],
      },
    })
    const receipt = await this.submitQuery(query)
    return unwrapXYList(unwrapOK(parse(Result.unwrap(receipt))))
  }

}

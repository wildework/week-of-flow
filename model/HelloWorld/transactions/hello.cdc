import HelloWorld from "../contract.cdc"

transaction {
  prepare(account: AuthAccount) {}
  execute {
    log(HelloWorld.hello())
  }
}
 
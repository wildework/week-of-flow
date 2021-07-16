import HelloWorld from "../contracts/HelloWorld.cdc"

transaction {
  prepare(account: AuthAccount) {}
  execute {
    log(HelloWorld.hello())
  }
}
 
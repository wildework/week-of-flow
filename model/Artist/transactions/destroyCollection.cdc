import Artist from "../contract.cdc"

transaction() {
  prepare(account: AuthAccount) {
    account.unlink(/public/PictureReceiver)
    let collection <- account.load<@Artist.Collection>(from: /storage/PictureCollection)
    destroy collection
  }
}
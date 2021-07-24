import Artist from "../contract.cdc"

transaction() {
  prepare(account: AuthAccount) {
    account.save<@Artist.Collection>(
      <- Artist.createCollection(),
      to: /storage/PictureCollection
    )
    account.link<&{Artist.PictureReceiver}>(
      /public/PictureReceiver,
      target: /storage/PictureCollection
    )
  }
}
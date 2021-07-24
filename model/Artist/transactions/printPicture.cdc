import Artist from "../contract.cdc"

transaction(canvas: String) {
  
  let picture: @Artist.Picture?
  let collectionRef: &{Artist.PictureReceiver}

  prepare(account: AuthAccount) {
    let printerRef = getAccount(0x01cf0e2f2f715450)
      .getCapability<&Artist.Printer>(/public/PicturePrinter)
      .borrow()
      ?? panic("Couldn't borrow printer reference.")
      
    self.picture <- printerRef.print(pixels: canvas)
    self.collectionRef = account
      .getCapability<&{Artist.PictureReceiver}>(/public/PictureReceiver)
      .borrow()
      ?? panic("Couldn't borrow picture receiver reference.")
  }
  execute {
    if self.picture == nil {
      destroy self.picture
    } else {
      self.collectionRef.deposit(picture: <- self.picture!)
    }
  }
}
 
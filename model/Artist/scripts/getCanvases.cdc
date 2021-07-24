import Artist from "../contract.cdc"

pub fun main(address: Address): [Artist.Canvas] {
  let account = getAccount(address)
  let pictureReceiverRef = account
    .getCapability<&{Artist.PictureReceiver}>(/public/PictureReceiver)
    .borrow()
    ?? panic("Couldn't borrow picture receiver reference.")

  return pictureReceiverRef.getCanvases()
}
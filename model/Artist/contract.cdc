pub contract Artist {

  pub event PrinterCreated()
  pub event PicturePrintSuccess(pixels: String)
  pub event PicturePrintFailure(pixels: String)
  pub event PictureDeposit(pixels: String)
  pub event CollectionCreated()

  // A structure that will store a two dimensional canvas made up of ASCII
  // characters (usually one character to indicate an on pixel, and one for off).
  pub struct Canvas {

    pub let width: UInt8
    pub let height: UInt8
    pub let pixels: String

    init(width: UInt8, height: UInt8, pixels: String) {
      self.width = width
      self.height = height
      // The following canvas
      // 123
      // 456
      // 789
      // should be serialized as
      // 123456789
      self.pixels = pixels
    }
    
  }

  // A resource that will store a single canvas
  pub resource Picture {

    pub let canvas: Canvas
    
    init(canvas: Canvas) {
      self.canvas = canvas
    }
  }

  pub resource interface PictureReceiver {
    pub fun deposit(picture: @Picture)
    pub fun getCanvases(): [Canvas]
  }

  pub resource Collection: PictureReceiver {
    pub let pictures: @[Picture]

    pub fun deposit(picture: @Picture) {
      let pixels = picture.canvas.pixels
      self.pictures.append(<- picture)
      emit PictureDeposit(pixels: pixels)
    }
    pub fun getCanvases(): [Canvas] {
      var canvases: [Canvas] = []
      var index = 0
      while index < self.pictures.length {
        canvases.append(
          self.pictures[index].canvas
        )
        index = index + 1
      }

      return canvases;
    }

    init() {
      self.pictures <- []
    }
    destroy() {
      destroy self.pictures
    }
  }

  pub fun createCollection(): @Collection {
    emit CollectionCreated()
    return <- create Collection()
  }

  // Printer ensures that only one picture can be printed for each canvas.
  // It also ensures each canvas is correctly formatted (dimensions and pixels).
  pub resource Printer {
    pub let width: UInt8
    pub let height: UInt8
    pub let prints: [String]

    init(width: UInt8, height: UInt8) {
      self.width = width;
      self.height = height;
      self.prints = []
    }

    // possible synonyms for the word "canvas"
    pub fun print(pixels: String): @Picture? {
      // Canvas needs to fit Printer's dimensions.
      if pixels.length != Int(self.width * self.height) {
        return nil
      }

      // Canvas can only use visible ASCII characters.
      for symbol in pixels.utf8 {
        if symbol < 32 || symbol > 126 {
          return nil
        }
      }

      // Printer is only allowed to print unique canvases.
      if self.prints.contains(pixels) == false {
        let canvas = Canvas(width: self.width, height: self.height, pixels: pixels)
        let picture <- create Picture(canvas: canvas)
        self.prints.append(canvas.pixels)

        emit PicturePrintSuccess(pixels: canvas.pixels)

        return <- picture
      } else {
        emit PicturePrintFailure(pixels: pixels)
        return nil
      }
    }
  }

  init() {
    self.account.save(
      <- create Printer(width: 5, height: 5),
      to: /storage/PicturePrinter
    )
    emit PrinterCreated()
    self.account.link<&Printer>(
      /public/PicturePrinter,
      target: /storage/PicturePrinter
    )

    self.account.save(
      <- self.createCollection(),
      to: /storage/PictureCollection
    )
    self.account.link<&{PictureReceiver}>(
      /public/PictureReceiver,
      target: /storage/PictureCollection
    )
  }
}
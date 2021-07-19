// A resource that will store a two dimensional canvas made up of ASCII
// characters (usually one character to indicate an on pixel, and one for off).
pub resource Picture {
  pub let width: UInt8
  pub let height: UInt8
  pub let canvas: String
  
  init(canvas: String, width: UInt8, height: UInt8) {
    self.width = width
    self.height = height
    // The following canvas
    // 123
    // 456
    // 789
    // should be serialized as
    // 123456789
    self.canvas = canvas
  }

  pub fun getCanvasRow(_ row: UInt8): String {
    return self.canvas.slice(
      from: Int(row * self.width),
      upTo: Int((row + 1) * self.width)
    )
  }
}

// Printer ensures that only one picture can be printed for each canvas.
// It also ensures each canvas is correctly formatted (dimensions and pixels).
pub resource Printer {
  pub let width: UInt8
  pub let height: UInt8
  pub let onPixel: UInt8
  pub let offPixel: UInt8
  pub let prints: [String]

  init(width: UInt8, height: UInt8, onPixel: UInt8, offPixel: UInt8) {
    self.width = width;
    self.height = height;
    self.onPixel = onPixel;
    self.offPixel = offPixel;
    self.prints = []
  }

  // possible synonyms for the word "canvas"
  pub fun print(canvas: String): @Picture? {
    // Canvas needs to fit Printer's dimensions.
    if canvas.length != Int(self.width * self.height) {
      return nil
    }

    // Canvas can only use on/off pixels (set using ASCII character codes).
    for symbol in canvas.utf8 {
      if symbol != self.onPixel && symbol != self.offPixel {
        return nil
      }
    }

    // Printer is only allowed to print unique canvases.
    if self.prints.contains(canvas) == false {
      self.prints.append(canvas)
      return <- create Picture(canvas: canvas, width: self.width, height: self.height)
    } else {
      return nil
    }
  }
}

// String array serializer.
pub fun serializeStringArray(_ lines: [String]): String {
  var buffer = ""
  for line in lines {
    buffer = buffer.concat(line)
  }

  return buffer
}

// A helper function to display how each picture looks.
pub fun display(pictureRef: &Picture) {
  var iteration: Int8 = -1
  while (iteration <= Int8(pictureRef.height)) {
    // Add a decorative frame around the picture.
    if iteration == -1 || iteration == Int8(pictureRef.height) {
      log("+-----+")
    } else {
      log("|".concat(pictureRef.getCanvasRow(UInt8(iteration))).concat("|"))
    }
    iteration = iteration + 1
  }
}

pub fun main() {
  // "*" - onPixel
  // " " - offPixel
  let printer <- create Printer(width: 5, height: 5, onPixel: 42, offPixel: 32)

  let canvasX: [String] = [
    "*   *",
    " * * ",
    "  *  ",
    " * * ",
    "*   *"
  ]
  
  let pictureX <- printer.print(canvas: serializeStringArray(canvasX))!
  let pictureXRef: &Picture = &pictureX as &Picture

  display(pictureRef: pictureXRef)
  // "+-----+"
  // "|*   *|"
  // "| * * |"
  // "|  *  |"
  // "| * * |"
  // "|*   *|"
  // "+-----+"

  let pictureXDuplicate <- printer.print(canvas: serializeStringArray(canvasX))
  log(pictureXDuplicate == nil)
  // true

  let canvasOne = [
    "   * ",
    "  ** ",
    " * * ",
    "   * ",
    "   * "
  ]
  let pictureOne <- printer.print(canvas: serializeStringArray(canvasOne))!
  let pictureOneRef: &Picture = &pictureOne as &Picture
  display(pictureRef: pictureOneRef)
  // "+-----+"
  // "|   * |"
  // "|  ** |"
  // "| * * |"
  // "|   * |"
  // "|   * |"
  // "+-----+"

  let pictures: @[Picture] <- []

  pictures.append(<- pictureX)
  pictures.append(<- pictureOne)

  let picturesRef = &pictures as &[Picture]

  destroy pictures

  destroy pictureXDuplicate

  destroy printer
}
pub contract HelloWorld {
  pub let greeting: String

  init() {
    self.greeting = "Hello, World!"
  }

  pub fun hello(): String {
    return self.greeting
  }
}
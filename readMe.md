# Concepts to Cover

+ Contract
+ Resource (Composite Type)
+ Event
+ Interface
  + Restricted types
+ Functions
  + Function Preconditions and Postconditions
+ Optionals
+ References
+ Capabilities
+ Access Control

+ Script
+ Transactions

## Types to Cover

- UInt64
- UFix64
- Address
- AuthAccount
- Array
- Dictionary

# Schedule

## Day 1

- Types
- Functions
- Contract
- Transaction
- Script

## Day 2

- Resource (Composite Type)
- Interface
  - Restricted types
- Optionals
- References
- Capabilities

## Day 3

- Flow CLI
- Flow Emulator

## Day 4

- Transaction Lifecycle
- Event
- Function Preconditions and Postconditions
- Access Control

## Day 5

- Testnet

# Flow CLI

```sh
flow emulator start
```

```sh
flow keys generate --sig-algo "ECDSA_secp256k1"
```

```sh
flow accounts create \
  --key "2824549ffffe11edc1e170f0c1186b9a588444812cdfe9ec0c93df8b858679c0afb4f006a7c273c0fdd18f62e3632fb3f984a682a928fe3c2c82d845a1245137" \
  --sig-algo "ECDSA_secp256k1" \
  --signer "emulator-account"
```

```sh
flow transactions build ./transactions/test.cdc \
  --authorizer owner \
  --proposer owner \
  --payer owner \
  --filter payload \
  --save test.rlp
```

```sh
flow transactions sign ./test.rlp \
  --signer owner \
  --filter payload \
  --save test.signed.rlp
```

```sh
flow transactions send-signed ./test.signed.rlp
```

# Cadence Quirks

## 1. Iterating over a reference to an array

Initial idea

```
let numbers = [1, 2, 3]
let numbersRef = &numbers as &[Int]
for number in numbersRef {
  log(number)
}
```

Produces `expected array, got "&[Int]"`. This trick below works.

```
let numbers = [1, 2, 3]
let numbersRef = &numbers as &[Int]
for number in numbersRef.concat([]) {
  log(number)
}
```

## 2. Using `--update` with `flow project deploy`

It does not call `init()` a second time on the account.
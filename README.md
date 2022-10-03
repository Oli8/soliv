# soliv

**Smart contract library**

## Installation

```console
$ npm install soliv
```

## Usage

Once installed, you can use the contracts by importing them:

```solidity
pragma solidity ^0.8.0;

import "soliv/contracts/access/TimeLock.sol";

contract MyDapp is TimeLock {
    constructor() TimeLock(3 days) {}
}
```

## Contracts

### [Access](contracts/access/)
- [TimeLock](contracts/access/TimeLock.sol)

## Security

This software is provided on an "as is" basis.\
We do not give any warranties and will not be liable for any loss incurred through any use of this codebase.

## Donate

Any donation is greatly appreciated :heart:

| Source          | Link / Address                             |
| :-------------- | :------------------------------------------|
| Github Sponsor  | https://github.com/sponsors/Oli8           |
| PayPal          | https://paypal.me/OliCrt                   |
| Bitcoin         | 1Ez3Ts2WShUcbeGCjhZapdxVDK77DbYjdU         |
| Ethereum        | 0x6cd3d316a6ee6d210894981e1fcc83a00a27ede2 |

## Contribute

Contributions are welcome!\
Feel free to get in touch if you have any suggestions

## License

Soliv is released under the [MIT License](LICENSE).

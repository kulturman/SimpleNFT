# SimpleNFT

SimpleNFT is an educational ERC721 implementation built with [Foundry](https://github.com/foundry-rs/foundry). The contract reimplements the core ERC721 functionality from scratch and includes enumeration, metadata, and basic minting logic.

The repository contains:

- `src/SimpleNFT.sol` – the main NFT contract
- `src/interfaces/` – custom interface definitions used by the contract
- `src/test/` – helper contracts for tests
- `script/` – a deployment script
- `test/` – a comprehensive test suite

## Contract Features

- **Minting** – the owner can mint tokens for any address. Other users can mint via `mintSimpleNFT` by sending `TOKEN_UNIT_COST` wei per token.
- **Enumeration** – `totalSupply`, `tokenByIndex`, and `tokenOfOwnerByIndex` are implemented for easy token discovery.
- **Reveal mechanism** – tokens initially return a placeholder URI. After `revealTimestamp` the owner can call `reveal` to expose the real metadata stored at `baseUrl`.
- **Withdraw** – collected ether can be withdrawn by the contract owner after `withdrawTimestamp`.
- **Ownership transfer** – pending/accept pattern for transferring contract ownership.

See `src/SimpleNFT.sol` for full details.

## Getting Started

1. Install Foundry (requires Rust). Follow the instructions from the [Foundry Book](https://book.getfoundry.sh/). Once installed, make sure `forge` is available in your `PATH`.
2. Clone this repository and initialise submodules to pull `forge-std` and `openzeppelin-contracts`:

```bash
git submodule update --init --recursive
```

3. Run the tests:

```bash
forge test
```

4. Build the contracts:

```bash
forge build
```

## Deployment

The deployment script is located at `script/SimpleNFT.s.sol`. It expects environment variables for your Sepolia RPC endpoint and private key. Example:

```bash
export SEPOLIA_URL=https://sepolia.infura.io/v3/<project_id>
export SEPOLIA_PRIVATE_KEY=<your_private_key>
forge script script/SimpleNFT.s.sol:CounterScript --rpc-url $SEPOLIA_URL --private-key $SEPOLIA_PRIVATE_KEY --broadcast
```

Transaction logs from previous broadcasts are stored in the `broadcast/` directory.

## Directory Layout

```
├── src                # Contract sources
│   ├── SimpleNFT.sol
│   ├── interfaces
│   └── test           # Test helper contracts
├── script             # Deployment script
├── test               # Forge tests
└── foundry.toml       # Project configuration
```

## License

This project is licensed under the MIT License. See `LICENSE` if present.

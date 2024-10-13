![FlickArena Logo](assets/logo.png)

# FlickArena

FlickArena is an innovative on-chain game that combines the excitement of physical dart throwing with blockchain technology.

## System Design

![System Design](assets/sytem-design-aptos.png)

## Overview

FlickArena integrates a physical dart board with smart contracts, creating a unique gaming experience where players' real-world dart throws are recorded and verified on Aptos blockchain.

## Demo Video

https://youtu.be/SoAa28u1Q9I

## Screenshots

![Game Play](assets/game-play.jpeg)
![Winner](assets/winner.jpeg)

## Features

- Physical dart board integration
- Blockchain-based score verification
- Smart contract-powered gameplay
- Token rewards for skilled players

## How It Works

1. Players throw darts at the physical board
2. Sensors capture throw data and send it to our iOS app through BLE
3. Data is sent to the blockchain
4. Smart contracts verify and record scores
5. Players earn tokens based on the game result

## Technology Stack

- [Aptos](https://aptos.dev/en) blockchain
- Move smart contracts
- IoT sensors for dart board
- [Web3Atuh](https://web3auth.io/) for user boarding and key management
- [Aptos](https://aptos.dev/en/build/sdks/community-sdks/swift-sdk) Swift SDK for mobile integration

### Contract Address on Aptos Testnet

- Game contract: https://explorer.aptoslabs.com/account/0x149a7bf28cd1d8bdb1bc3328ebbe330a10f63035f4e1b79aad1cdc8baa64ab69/modules/code/game?network=testnet

## Getting Started

Host initialize a game with the game contract and share the game address with players.
After the other player send funds to the game contract, they can start the game.

## Future Development

To create a social experience where you can challenge your friends to a game of FlickArena.

## Contributing

We welcome contributions! Please open a pull request here on github.

## License

Apache-2.0 license

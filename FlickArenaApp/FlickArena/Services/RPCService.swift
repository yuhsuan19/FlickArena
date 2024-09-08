//
//  RPCService.swift
//  FlickArena
//
//  Created by Shane Chi on 2024/9/8.
//

import Foundation
import web3
import Combine
import BigInt

final class RPCService {

    let addressValueSubject = CurrentValueSubject<String?, Never>(nil)
    let nativeTokenBalValueSubject = CurrentValueSubject<BigUInt?, Never>(nil)

    let gameContractSubject = PassthroughSubject<String, Never>()
    let secondPlayerAddressSubject = PassthroughSubject<String, Never>()

    private let user: EthereumSingleKeyStorageProtocol?
    private var account: EthereumAccount?
    private var address: EthereumAddress? { account?.address }

    private let rpcURL: String
    private let chainId: String
    private var latestBlock = 0

    private var client: EthereumClientProtocol?


    init(user: EthereumSingleKeyStorageProtocol, rpcURL: String, chainId: String) {
        self.user = user

        self.rpcURL = rpcURL
        self.chainId = chainId

        setUp()
    }

    func getPlayer2(contract: EthereumAddress) async {
        guard let client else { return }
        let getPlayerFunction = GetPlayers(contract: contract)

        while true {
            do {
                let response = try await getPlayerFunction.call(withClient: client, responseType: GetPlayers.Response.self)

                if response.addresses.count == 2 {
                    let strippedAddress = String(response.addresses[1].toChecksumAddress().dropFirst(2))
                    let length = 40
                    let startIndex = strippedAddress.index(strippedAddress.startIndex, offsetBy: strippedAddress.count - length)
                    let range = startIndex..<strippedAddress.endIndex
                    let trimmedAddress = String(strippedAddress[range])
                    let formattedAddress = "0x" + trimmedAddress.lowercased()

                    secondPlayerAddressSubject.send(formattedAddress)
                    break
                } else {
                    print("Waiting for more players... Current count: \(response.addresses.count)")
                    try await Task.sleep(nanoseconds: 3_000_000_000)
                }
            } catch {
                print("Error fetching players: \(error)")
                break
            }
        }
    }

    func getCreateGameTxReceipt(txHash: String) async {
        guard let client else { return }

        while true {
            do {
                if let receipt = try? await client.eth_getTransactionReceipt(txHash: txHash) {
                    let logData = receipt.logs[0].data
                    
                    let start = logData.index(logData.startIndex, offsetBy: 26)
                    let end = logData.index(logData.startIndex, offsetBy: 66)
                    let range = start..<end

                    let gameContractAddress = "0x\(logData[range])"
                    print(gameContractAddress)
                    gameContractSubject.send(gameContractAddress)
                    break
                } else {
                    print("polling")
                    try await Task.sleep(nanoseconds: 1_000_000_000)
                }
            } catch {
                print(error)
                break
            }
        }
    }


    func getBalance() {
        guard let client, let address else { return }
        Task {
            let blockChanged = await checkLatestBlockChanged()
            guard blockChanged == true else { return }
            
            do {
                let balance = try await client.eth_getBalance(address: address, block: .Latest)
                print("Native token balance: \(balance)")
                nativeTokenBalValueSubject.send(balance)
            } catch {
                print(error)
            }
        }
    }

    func createGame() async {
        guard let account, let address, let client else { return }
        let gasPrice = try? await client.eth_gasPrice()

        let createGameFunction = CreateGame(
            from: address,
            contract: "0x714f2Cf5CaDf99E635C18865fa65f7697F9A6abc",
            targetScore: BigUInt(301),
            maxRounds: BigUInt(10)
        )

        do {
            let estimationTx = try createGameFunction.transaction(value: BigUInt(10), gasPrice: gasPrice)
            let estimatedGas = try await client.eth_estimateGas(estimationTx)
            let tx = try createGameFunction.transaction(
                value: BigUInt(10),
                gasPrice: gasPrice,
                gasLimit: estimatedGas.multiplied(by: BigUInt(BigInt(1.2)))
            )
            let txHash = try await client.eth_sendRawTransaction(tx, withAccount: account)
            print("Create game tx hash: \(txHash)")
            await getCreateGameTxReceipt(txHash: txHash)
        } catch {
            print(error)
        }
    }

    func dartOn(gameContract: EthereumAddress, player: EthereumAddress, score: Int) async {
        guard let account, let address, let client else { return }
        let gasPrice = try? await client.eth_gasPrice()

        let flickDart = FlickDart(
            from: address,
            contract: gameContract,
            score: BigUInt(score),
            player: player
        )

        do {
            let estimationTx = try flickDart.transaction(gasPrice: gasPrice)
            let estimatedGas = try await client.eth_estimateGas(estimationTx)
            let tx = try flickDart.transaction(
                gasPrice: gasPrice,
                gasLimit: estimatedGas.multiplied(by: BigUInt(BigInt(1.2)))
            )
            let txHash = try await client.eth_sendRawTransaction(tx, withAccount: account)
            print("Flick Dart tx hash: \(txHash)")
        } catch {
            print(error)
        }
    }
}

// MARK: - Private functions
extension RPCService {
    private func setUp() {
        guard let user else { return }
        do {
            client = EthereumHttpClient(
                url: URL(string: rpcURL)!,
                network: .fromString(chainId)
            )
            account = try EthereumAccount(keyStorage: user)
            addressValueSubject.send(address?.asString())
        } catch {
            print("Fail to load sepolia client")
        }
    }

    private func checkLatestBlockChanged() async -> Bool {
        return await withCheckedContinuation({ continuation in
            client?.eth_blockNumber { [weak self] result in
                switch result {
                case .success(let val):
                    if self?.latestBlock != val {
                        self?.latestBlock = val
                        continuation.resume(returning: true)
                    } else {
                        continuation.resume(returning: false)
                    }
                case .failure:
                    continuation.resume(returning: false)
                }
            }
        })
    }
}

public struct GetPlayers: ABIFunction {
    public var contract: web3.EthereumAddress

    public var gasPrice: BigUInt? = nil
    public var gasLimit: BigUInt? = nil
    public var from: web3.EthereumAddress? = nil
    
    public static var name: String = "getPlayers"

    init(contract: EthereumAddress ) {
        self.contract = contract
    }

    public func encode(to encoder: web3.ABIFunctionEncoder) throws {}

    struct Response: ABIResponse {
        init?(values: [web3.ABIDecoder.DecodedValue]) throws {
            return nil
        }
        
        static var types: [ABIType.Type] = [ABIArray<EthereumAddress>.self]
        let addresses: [EthereumAddress]

        init?(data: String) throws {
            let strippedInput = String(data.dropFirst(2))

            let halfIndex = strippedInput.index(strippedInput.startIndex, offsetBy: strippedInput.count / 2)
            let firstHalf = "0x\(String(strippedInput[..<halfIndex]))"
            let secondHalf = "0x\(String(strippedInput[halfIndex...]))"

            if EthereumAddress(stringLiteral: secondHalf) != EthereumAddress.zero {
                self.addresses = [EthereumAddress(stringLiteral: firstHalf), EthereumAddress(stringLiteral: secondHalf)]
            } else {
                self.addresses = [EthereumAddress(stringLiteral: firstHalf)]
            }
        }
    }
}

struct FlickDart: ABIFunction {
    public var from: web3.EthereumAddress?

    public static let name = "flickDart"
    public var gasPrice: BigUInt? = nil
    public var gasLimit: BigUInt? = nil
    public var contract: EthereumAddress
    
    public let score: BigUInt
    public let player: EthereumAddress

    init(from: web3.EthereumAddress? = nil, gasPrice: BigUInt? = nil, gasLimit: BigUInt? = nil, contract: EthereumAddress, score: BigUInt, player: EthereumAddress) {
        self.from = from
        self.gasPrice = gasPrice
        self.gasLimit = gasLimit
        self.contract = contract
        self.score = score
        self.player = player
    }

    public func encode(to encoder: ABIFunctionEncoder) throws {
        try encoder.encode(score)
        try encoder.encode(player)
    }
}

public struct CreateGame: ABIFunction {
    public var from: web3.EthereumAddress?
    
    public static let name = "createGame"
    public var gasPrice: BigUInt? = nil
    public var gasLimit: BigUInt? = nil
    public var contract: EthereumAddress

    public let targetScore: BigUInt
    public let maxRounds: BigUInt

    init(
        from: web3.EthereumAddress?,
        contract: EthereumAddress,
        targetScore: BigUInt,
        maxRounds: BigUInt
    ) {
        self.from = from
        self.contract = contract
        self.targetScore = targetScore
        self.maxRounds = maxRounds
    }

    public func encode(to encoder: ABIFunctionEncoder) throws {
        try encoder.encode(targetScore)
        try encoder.encode(maxRounds)
    }
}




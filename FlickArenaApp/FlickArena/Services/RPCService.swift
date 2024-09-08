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


//    func loadSepoliaClient() {
//        do {
//            sepoliaClient = EthereumHttpClient(url: URL(string: RPC_URL)!, network: .fromString("\(chainID)"))
//            account = try EthereumAccount(keyStorage: user! as EthereumSingleKeyStorageProtocol )
//
//            print(address)
//        } catch {
//            print("Fail to load sepolia client")
//        }
//    }

//    func transferBLT() async {
//        guard let account, let address, let sepoliaClient else { return }
//
//        let gasPrice = try? await sepoliaClient.eth_gasPrice()
//
//        var function = Transfer(contract: "0x164914A9270fcE48d6172Fac2C1e0eC9023a1f43", from: address, to: "0x444d6CEb52453a1E1918455387Ed2eE9179527Bf", value: 3000000000)
//        function.gasPrice = gasPrice
//
//        if let transaction = try? function.transaction(gasPrice: gasPrice) {
//            do {
//                let estimatedGas = try await sepoliaClient.eth_estimateGas(transaction)
//                function.gasLimit = estimatedGas
//                let tx = try function.transaction(gasPrice: gasPrice, gasLimit: estimatedGas)
//                let txHash = try await sepoliaClient.eth_sendRawTransaction(tx, withAccount: account)
//                print(txHash)
//            } catch {
//                print(error)
//            }
//        }
//    }

//public struct Transfer: ABIFunction {
//    public static let name = "transfer"
//    public var gasPrice: BigUInt? = nil
//    public var gasLimit: BigUInt? = nil
//    public var contract: EthereumAddress
//    public let from: EthereumAddress?
//
//    public let to: EthereumAddress
//    public let value: BigUInt
//
//    public init(contract: EthereumAddress,
//                from: EthereumAddress? = nil,
//                to: EthereumAddress,
//                value: BigUInt) {
//        self.contract = contract
//        self.from = from
//        self.to = to
//        self.value = value
//    }
//
//    public func encode(to encoder: ABIFunctionEncoder) throws {
//        try encoder.encode(to)
//        try encoder.encode(value)
//    }
//}

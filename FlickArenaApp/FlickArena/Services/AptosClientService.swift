//
//  AptosClientService.swift
//  FlickArena
//
//  Created by Shane Chi on 2024/9/29.
//

import Foundation
import Core
import Aptos
import Transactions
import Types
import Combine

final class AptosClientService {

    let gameInitializedSubject: PassthroughSubject<Void, Never> = .init()
    let secondPlayerAddressSubject = PassthroughSubject<String, Never>()
    let account: Account.Ed25519Account

    private let client = Aptos(aptosConfig: .testnet)

    init?(rawPrivateKey: String) {
        do {
            let ed25519PrivateKey = try Ed25519PrivateKey(rawPrivateKey)
            account = try Account.fromPrivateKey(ed25519PrivateKey)
        } catch {
            return nil
        }
    }

    func initializeGame(contractAddress: String) {
        let targetScore: UInt64 = 301
        let maxRounds: UInt64 = 10

        Task {
            do {
                let rawTxn = try await client.transaction.build.simple(
                    sender: account.accountAddress,
                    data: InputEntryFunctionData(
                        function: "\(contractAddress)::game::initialize",
                        typeArguments: [],
                        functionArguments: [targetScore, maxRounds ]
                    )
                )
                let authenticator = try await client.transaction.sign.transaction(signer: account, transaction: rawTxn)
                let response = try await client.transaction.submit.simple(transaction: rawTxn, senderAuthenticator: authenticator)
                let txn = try await client.transaction.waitForTransaction(transactionHash: response.hash)
                let transaction = try await client.transaction.getTransactionByHash(txn.hash)
                print("Transaction Details: \(transaction)")

                registerAndBet(contractAddress: contractAddress)
            } catch {
                print(error)
            }
        }
    }

    func registerAndBet(contractAddress: String) {
        let betAmount: UInt64 = 10_000
        
        Task {
            do {
                let rawTxn = try await client.transaction.build.simple(
                    sender: account.accountAddress,
                    data: InputEntryFunctionData(
                        function: "\(contractAddress)::game::register_and_bet",
                        typeArguments: [],
                        functionArguments: [account.accountAddress.toString(), betAmount]
                    )
                )
                let authenticator = try await client.transaction.sign.transaction(signer: account, transaction: rawTxn)
                let response = try await client.transaction.submit.simple(transaction: rawTxn, senderAuthenticator: authenticator)
                let txn = try await client.transaction.waitForTransaction(transactionHash: response.hash)
                let transaction = try await client.transaction.getTransactionByHash(txn.hash)
                print("Transaction Details: \(transaction)")
                gameInitializedSubject.send(())
            }
        }
    }

    func getPlayer2(contractAddress: String) async {
        while true {
            do {
                let payload = InputViewFunctionData(
                    function: "\(contractAddress)::game::get_player_info",
                    functionArguments: [account.accountAddress.toString(), 1]
                )
                if let results = try? await client.general.view(payload: payload) {
                    let address = "\(results[0])"
                    secondPlayerAddressSubject.send(address)
                    break
                } else {
                    try await Task.sleep(nanoseconds: 3_000_000_000)
                }
            } catch {
                print("Error fetching player2: \(error)")
                break
            }
        }
    }

    func dartOn(gameContract: String, player: String, score: UInt64) {

    }
}

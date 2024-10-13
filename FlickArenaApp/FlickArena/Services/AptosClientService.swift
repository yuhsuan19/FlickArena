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

    func view(payload: InputViewFunctionData) async -> Result<[MoveValue], Error> {
        do {
            let results = try await client.general.view(payload: payload)
            return .success(results)
        } catch {
            return .failure(error)
        }

    }

    @discardableResult
    func sendTransaction(functionData: InputGenerateTransactionPayloadData) async -> Result<TransactionResponse, Error> {
        do {
            let rawTransaction = try await client.transaction.build.simple(
                sender: account.accountAddress,
                data: functionData
            )
            let authenticator = try await client.transaction.sign.transaction(signer: account, transaction: rawTransaction)
            let response = try await client.transaction.submit.simple(transaction: rawTransaction, senderAuthenticator: authenticator)
            let transaction = try await client.transaction.waitForTransaction(transactionHash: response.hash)
            let transactionResponse = try await client.transaction.getTransactionByHash(transaction.hash)
            return .success(transactionResponse)
        } catch {
            print(error)
            return .failure(error)
        }
    }
}

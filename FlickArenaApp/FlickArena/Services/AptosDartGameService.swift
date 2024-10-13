//
//  AptosDartGameService.swift
//  FlickArena
//
//  Created by Shane Chi on 2024/10/11.
//

import Foundation
import Core
import Aptos
import Transactions
import Types

final class AptosDartGameService {
    let gameContractAddress: String
    var hostAddress: String?

    private let clientService: AptosClientService

    init(clientService: AptosClientService, contractAddress: String) {
        self.clientService = clientService
        self.gameContractAddress = contractAddress
    }

    func createGame() async -> Result<Void, Error> {
        do {
            try await initializeGame()
            hostAddress = clientService.account.accountAddress.toString()
            try await registerAndBet()
            return .success(())
        } catch {
            return .failure(error)
        }
    }

    func pollingPlayer2() async -> String? {
        guard let hostAddress else { return nil }

        let payload = InputViewFunctionData(
            function: "\(gameContractAddress)::game::get_player_info",
            functionArguments: [hostAddress, 1]
        )

        while true {
            do {
                let result = await clientService.view(payload: payload)
                switch result {
                case let .success(data):
                    return "\(data[0])"
                case .failure:
                    try await Task.sleep(nanoseconds: 3_000_000_000)
                }
            } catch {
                print("Error fetching player2: \(error)")
                return nil
            }
        }
    }

    func dartOn(playerAddress: String, score: Int) {
        Task {
            let functionData = InputEntryFunctionData(
                function: "\(gameContractAddress)::game::flick_dart",
                typeArguments: [],
                functionArguments: [playerAddress, UInt64(score)]
            )
            await clientService.sendTransaction(functionData: functionData)
        }
    }
}

// MARK: - Private functions
extension AptosDartGameService {
    private func initializeGame(targetScore: Int = 301, numberOfRounds: Int = 10) async throws {
        let functionData = InputEntryFunctionData(
            function: "\(gameContractAddress)::game::initialize",
            typeArguments: [],
            functionArguments: [
                UInt64(targetScore),
                UInt64(numberOfRounds)
            ]
        )
        let result = await clientService.sendTransaction(functionData: functionData)
        switch result {
        case let .success(response):
            print(response)
        case let .failure(error):
            throw error
        }
    }

    private func registerAndBet(betAmount: UInt64 = 10_000) async throws {
        guard let hostAddress else { return }

        let functionData = InputEntryFunctionData(
            function: "\(gameContractAddress)::game::register_and_bet",
            typeArguments: [],
            functionArguments: [
                hostAddress,
                betAmount
            ]
        )
        let result = await clientService.sendTransaction(functionData: functionData)
        switch result {
        case let .success(response):
            print(response)
        case let .failure(error):
            throw error
        }
    }
}

//
//  LobbyViewModel.swift
//  FlickArena
//
//  Created by Shane Chi on 2024/9/6.
//

import Foundation
import Web3Auth
import Combine

final class LobbyViewModel: ObservableObject {
    let web3AuthService: Web3AuthService
    let dartBoardService: DartBoardService
    var aptosClientService: AptosClientService?

    @Published var gameContractAddress: String = "0x149a7bf28cd1d8bdb1bc3328ebbe330a10f63035f4e1b79aad1cdc8baa64ab69"
    @Published var isGameCreated: Bool = false

    var user: Web3AuthState? {
        web3AuthService.user
    }

    private var cancellables = Set<AnyCancellable>()

    init(web3AuthService: Web3AuthService, dartBoardService: DartBoardService) {
        self.web3AuthService = web3AuthService
        self.dartBoardService = dartBoardService

        if let privateKey = web3AuthService.user?.privKey {
            self.aptosClientService = AptosClientService(rawPrivateKey: privateKey)
        }

        setUpBindings()
    }

    func createGame() {
//        aptosClientService?.initializeGame(contractAddress: gameContractAddress)
        isGameCreated = true
    }
}

// MARK: - Private functions
extension LobbyViewModel {
    private func setUpBindings() {
        aptosClientService?.gameInitializedSubject
            .sink { [weak self] in
                DispatchQueue.main.async {
                    self?.isGameCreated = true
                }
            }
            .store(in: &cancellables)
    }
}

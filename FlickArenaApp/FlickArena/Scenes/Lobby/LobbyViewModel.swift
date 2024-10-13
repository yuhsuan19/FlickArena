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
    var aptosDartGameService: AptosDartGameService?

    @Published var gameContractAddress: String = "0x149a7bf28cd1d8bdb1bc3328ebbe330a10f63035f4e1b79aad1cdc8baa64ab69"
    @Published var isGameCreated: Bool = false

    init(
        web3AuthService: Web3AuthService,
        dartBoardService: DartBoardService
    ) {
        self.web3AuthService = web3AuthService
        self.dartBoardService = dartBoardService

        if let privateKey = web3AuthService.user?.privKey,
           let clientService = AptosClientService(rawPrivateKey: privateKey) {
            aptosDartGameService = AptosDartGameService(
                clientService: clientService,
                contractAddress: gameContractAddress
            )
        }
    }

    func createGame() {
        guard let aptosDartGameService else { return }
        Task {
            let result = await aptosDartGameService.createGame()
            switch result {
            case .success:
                setGameCreated()
            case let .failure(error):
                print("Fail to create new game: \(error)")
            }
        }
    }

    private func setGameCreated() {
        DispatchQueue.main.async { [weak self] in
            self?.isGameCreated = true
        }
    }
}

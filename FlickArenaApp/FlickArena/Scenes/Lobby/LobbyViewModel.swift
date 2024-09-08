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
    let rpcService: RPCService?
    let dartBoardService: DartBoardService

    @Published var gameHostAddress: String?
    @Published var gameHostNativeTokenBalance: String?
    @Published var gameContractAddress: String?
    @Published var isGameCreated: Bool = false

    var user: Web3AuthState? {
        web3AuthService.user
    }

    private var cancellables = Set<AnyCancellable>()

    init(web3AuthService: Web3AuthService, dartBoardService: DartBoardService) {
        self.web3AuthService = web3AuthService
        self.dartBoardService = dartBoardService

        if let user = web3AuthService.user {
            self.rpcService = RPCService(
                user: user,
                rpcURL: "https://sepolia.base.org",
                chainId: "84532"
            )
        } else {
            print("Fail to initialize RPCService")
            rpcService = nil
        }

        setUpBindings()
    }

    func getBalance() {
        rpcService?.getBalance()
    }

    func createGame() {
        Task {
            await rpcService?.createGame()
        }
    }
}

// MARK: - Private functions
extension LobbyViewModel {
    private func setUpBindings() {
        rpcService?.addressValueSubject
            .sink { [weak self] address in
                DispatchQueue.main.async {
                    self?.gameHostAddress = address
                    print("Game Host address: \(address)")
                }
            }
            .store(in: &cancellables)

        rpcService?.nativeTokenBalValueSubject
            .sink { [weak self] balance in
                DispatchQueue.main.async {
                    self?.gameHostNativeTokenBalance = balance?.description
                }
            }
            .store(in: &cancellables)

        rpcService?.gameContractSubject
            .sink { [weak self] contractAddress in
                DispatchQueue.main.async {
                    self?.gameContractAddress = contractAddress
                    self?.isGameCreated = true
                }
            }
            .store(in: &cancellables)
    }
}

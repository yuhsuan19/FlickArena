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

    @Published var gameHostAddress: String?
    @Published var gameHostNativeTokenBalance: String?

    var user: Web3AuthState? {
        web3AuthService.user
    }

    private var cancellables = Set<AnyCancellable>()

    init(web3AuthService: Web3AuthService) {
        self.web3AuthService = web3AuthService
        
        if let user = web3AuthService.user {
            self.rpcService = RPCService(
                user: user,
                rpcURL: "https://polygon-amoy.drpc.org",
                chainId: "80002"
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
}

// MARK: - Private functions
extension LobbyViewModel {
    private func setUpBindings() {
        rpcService?.addressValueSubject
            .sink { [weak self] address in
                self?.gameHostAddress = address
            }
            .store(in: &cancellables)

        rpcService?.nativeTokenBalValueSubject
            .sink { [weak self] balance in
                self?.gameHostNativeTokenBalance = balance?.description
            }
            .store(in: &cancellables)
    }
}

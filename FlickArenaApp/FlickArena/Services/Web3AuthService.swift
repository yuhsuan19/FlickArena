//
//  Web3AuthService.swift
//  FlickArena
//
//  Created by Shane Chi on 2024/9/6.
//

import Foundation
import Web3Auth
import Combine
import web3
import BigInt

final class Web3AuthService {
    let logInSuccessSubject = PassthroughSubject<Void, Never>()

    var web3Auth: Web3Auth?
    var user: Web3AuthState?

    static let CLIENT_ID = "BAIjcA1HywygiWMZwkliS7sE5mLX794KoDWn2ffEnAO6qRROb0mp71K8CezC6hF2iy6txKZzzUMXYOrZwKTmkJE"
    private let network: Network = .sapphire_devnet

    init() {
        Task {
            await setUp()
        }
    }

    func login(with email: String) async {
        do {
            let result = try await web3Auth?.login(
                W3ALoginParams(
                    loginProvider: .EMAIL_PASSWORDLESS,
                    extraLoginOptions: ExtraLoginOptions(login_hint: email)
                ))
            user = result
            logInSuccessSubject.send(())
        } catch {
            print("Error")
        }
    }
}

// MARK: - 
extension Web3AuthService{
    private func setUp() async {
        guard web3Auth == nil else { return }

        do {
            web3Auth = try await Web3Auth(W3AInitParams(
                clientId: Web3AuthService.CLIENT_ID,
                network: network,
                redirectUrl: "com.yuhsuan.FlickArena://auth"
            ))
        } catch {
            print("Something went wrong")
        }
    }
}

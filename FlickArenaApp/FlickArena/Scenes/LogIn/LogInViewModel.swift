//
//  LogInViewModel.swift
//  FlickArena
//
//  Created by Shane Chi on 2024/9/6.
//

import Foundation
import Combine

final class LogInViewModel: ObservableObject {

    let web3AuthService: Web3AuthService
    @Published var isLoggedIn: Bool = false

    private var cancellables = Set<AnyCancellable>()

    init(web3AuthService: Web3AuthService) {
        self.web3AuthService = web3AuthService
        setUpBindings()
    }

    func login(with email: String) async {
        await web3AuthService.login(with: email)
    }
}

// MAKR: - Private functions
extension LogInViewModel {
    private func setUpBindings() {
        web3AuthService.logInSuccessSubject
            .sink { [weak self] in
                DispatchQueue.main.async {
                    self?.isLoggedIn = true
                }
            }
            .store(in: &cancellables)
    }
}

//
//  LobbyViewModel.swift
//  FlickArena
//
//  Created by Shane Chi on 2024/9/6.
//

import Foundation
import Web3Auth

final class LobbyViewModel: ObservableObject {
    let web3AuthService: Web3AuthService
    var user: Web3AuthState? {
        web3AuthService.user
    }

    init(web3AuthService: Web3AuthService) {
        self.web3AuthService = web3AuthService
    }
}

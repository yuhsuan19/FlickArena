//
//  FlickArenaApp.swift
//  FlickArena
//
//  Created by Shane Chi on 2024/9/4.
//

import SwiftUI
import CoreBluetooth

@main
struct FlickArenaApp: App {
    private let dartBoardService: DartBoardService
    private let web3AuthService: Web3AuthService

    init() {
        dartBoardService = DartBoardService(centralManager: CBCentralManager())
        web3AuthService = Web3AuthService()
    }

    var body: some Scene {
        WindowGroup {
            let loginViewModel = LogInViewModel(web3AuthService: web3AuthService, dartBoardService: dartBoardService)
            NavigationStack {
                LogInScreen(viewModel: loginViewModel)
            }
        }
    }
}

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

    init() {
        dartBoardService = DartBoardService(centralManager: CBCentralManager())
    }

    var body: some Scene {
        WindowGroup {
            let zeroGameViewModel = ZeroOneGameViewModel(dartBoardService: dartBoardService)
            ZeroOneGameScreen(viewModel: zeroGameViewModel)
        }
    }
}

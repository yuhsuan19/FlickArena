//
//  ZeroOneGameScreen.swift
//  FlickArena
//
//  Created by Shane Chi on 2024/9/5.
//

import SwiftUI

struct ZeroOneGameScreen: View {

    @StateObject private var viewModel: ZeroOneGameViewModel

    init(viewModel: ZeroOneGameViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

import CoreBluetooth
#Preview {
    let viewModel = ZeroOneGameViewModel(
        dartBoardService: DartBoardService(
            centralManager: CBCentralManager()
        )
    )
    return ZeroOneGameScreen(viewModel: viewModel)
}

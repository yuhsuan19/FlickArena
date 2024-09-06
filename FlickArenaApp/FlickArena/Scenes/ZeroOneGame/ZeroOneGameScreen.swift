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
        if let winner = viewModel.winner {
            Text("\(winner.name) is the Winner!!!")
                .font(.system(size: 120, weight: .bold))
        } else {
            VStack(spacing: 12) {
                Text("Round \(viewModel.currentRound + 1)")
                    .font(.system(size: 40, weight: .bold))
                HStack {
                    ForEach(viewModel.playerDisplayModels) { displayModel in
                        VStack {
                            if displayModel.playerName == viewModel.players[viewModel.currentPlayerIndex].name {
                                Text(displayModel.playerName)
                                    .font(.system(size: 32, weight: .bold))
                                    .background(.green)
                            } else {
                                Text(displayModel.playerName)
                                    .font(.system(size: 32, weight: .bold))
                            }

                            Text(displayModel.currentScore)
                                .font(.system(size: 86, weight: .bold))
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                }
            }
            .padding()
        }
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

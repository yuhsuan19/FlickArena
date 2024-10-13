//
//  WaitPlayersScreen.swift
//  FlickArena
//
//  Created by Shane Chi on 2024/9/8.
//

import SwiftUI

struct WaitPlayersScreen: View {
    @StateObject private var viewModel: WaitPlayersViewModel

    init(viewModel: WaitPlayersViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Waiting for both players registered")
                .font(.system(size: 20, weight: .bold))
            Text("Game Contract Address: \(viewModel.gameContractAddress)")
            Image(uiImage: viewModel.generateGameContractQRCode())
                .resizable()
                .interpolation(.none)
                .scaledToFit()
                .frame(width: 120, height: 120)
                .background(.white)
            HStack(spacing: 30) {
                VStack(spacing: 16) {
                    Text("Player 1")
                        .bold()
                    Text(viewModel.player1Address ?? "Waiting for registered")
                }

                VStack(spacing: 16) {
                    Text("Player 2")
                        .bold()
                    Text(viewModel.player2Address ?? "Waiting for registered")
                }
            }
            .padding()
        }
        .padding()
        .onAppear {
            viewModel.startPollingPlayer2()
        }
        .navigationDestination(isPresented: $viewModel.canStartGame) {
            if let player1 = viewModel.player1Address,
               let player2 = viewModel.player2Address {
                let viewModel = ZeroOneGameViewModel(
                    dartBoardService: viewModel.dartBoardService,
                    dartGameService: viewModel.dartGameService,
                    players: [
                        GamePlayer(name: "Player1", address: player1),
                        GamePlayer(name: "Player2", address: player2)
                    ]
                )
                ZeroOneGameScreen(viewModel: viewModel)
            } else {
                EmptyView() // should not happen
            }
        }
    }
}

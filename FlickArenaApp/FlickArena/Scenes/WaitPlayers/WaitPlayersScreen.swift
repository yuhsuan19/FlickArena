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
            Image(uiImage: viewModel.generateQRCode(from: viewModel.gameContractAddress))
                .resizable()
                .interpolation(.none)
                .scaledToFit()
                .frame(width: 120, height: 120)
                .background(.white)
            HStack(spacing: 30) {
                VStack(spacing: 16) {
                    Text("Player 1")
                        .bold()
                    Text(viewModel.player1Address)
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
            viewModel.getPlayer2()
        }
        .navigationDestination(isPresented: $viewModel.canStartGame) {
            if let player2Address = viewModel.player2Address {
                let viewModel = ZeroOneGameViewModel(
                    dartBoardService: viewModel.dartBoardService,
                    rpcService: viewModel.rpcService,
                    players: [GamePlayer(name: "Player1", address: viewModel.player1Address),
                              GamePlayer(name: "Player2", address: player2Address)],
                    gameContractAddress: viewModel.gameContractAddress
                )
                ZeroOneGameScreen(viewModel: viewModel)
            } else {
                EmptyView() // should not happen
            }
        }
    }
}

//#Preview {
//    WaitPlayersScreen()
//}

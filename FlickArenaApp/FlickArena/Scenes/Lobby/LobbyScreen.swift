//
//  LobbyScreen.swift
//  FlickArena
//
//  Created by Shane Chi on 2024/9/6.
//

import SwiftUI

struct LobbyScreen: View {
    @StateObject private var viewModel: LobbyViewModel

    init(viewModel: LobbyViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Game Host Address:")
                .font(.system(size: 30, weight: .bold))
            Text(" \(viewModel.gameHostAddress ?? "loading...")")
                .font(.system(size: 24))
            Button(action: {
                viewModel.createGame()
            }) {
                Text("Create New Game")
                    .font(.system(size: 34))
                    .padding()
            }
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            Spacer()
        }
        .padding()
        .onAppear {
            viewModel.getBalance()
        }
        .navigationDestination(isPresented: $viewModel.isGameCreated) {
            if let rpcService = viewModel.rpcService,
               let gameContractAddress = viewModel.gameContractAddress,
               let gameHostAddress = viewModel.gameHostAddress {
                let viewModel = WaitPlayersViewModel(
                    rpcService: rpcService,
                    dartBoardService: viewModel.dartBoardService,
                    gameContractAddress: gameContractAddress,
                    player1Address: gameHostAddress
                )
                WaitPlayersScreen(viewModel: viewModel)
            } else {
                EmptyView() // should not happen
            }
        }
    }
}

//#Preview {
//    let viewModel = LobbyViewModel(web3AuthService: Web3AuthService())
//    return LobbyScreen(viewModel: viewModel)
//}

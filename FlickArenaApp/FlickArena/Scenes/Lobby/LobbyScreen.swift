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
            Text("Game Contrat Address:")
                .font(.system(size: 30, weight: .bold))
            Text(" \(viewModel.gameContractAddress)")
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
        .navigationDestination(isPresented: $viewModel.isGameCreated) {
            if let dartGameSevice = viewModel.aptosDartGameService {
                let viewModel = WaitPlayersViewModel(
                    dartGameService: dartGameSevice,
                    dartBoardService: viewModel.dartBoardService
                )
                WaitPlayersScreen(viewModel: viewModel)
            } else {
                EmptyView() // should not happen
            }
        }
    }
}

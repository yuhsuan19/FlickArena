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
            Text("Game Host Address: \(viewModel.gameHostAddress ?? "loading...")")
            Text("Game Host Balance: \(viewModel.gameHostNativeTokenBalance ?? "loading...")")
            Button(action: {

            }) {
                Text("Create New Game")
            }
            Spacer()
        }
        .padding()
        .onAppear {
            viewModel.getBalance()
        }
    }
}

#Preview {
    let viewModel = LobbyViewModel(web3AuthService: Web3AuthService())
    return LobbyScreen(viewModel: viewModel)
}

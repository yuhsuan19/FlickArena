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
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    let viewModel = LobbyViewModel(web3AuthService: Web3AuthService())
    return LobbyScreen(viewModel: viewModel)
}

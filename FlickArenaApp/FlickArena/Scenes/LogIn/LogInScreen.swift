//
//  LogInScreen.swift
//  FlickArena
//
//  Created by Shane Chi on 2024/9/6.
//

import SwiftUI

struct LogInScreen: View {
    @StateObject private var viewModel: LogInViewModel
    @State private var email: String = "shane.chi@portto.com"

    init(viewModel: LogInViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 40) {
            TextField("Enter your E-mail", text: $email)
                .font(.system(size: 50, weight: .black))
                .keyboardType(.emailAddress)

            Button(action: {
                Task {
                    await viewModel.login(with: email)
                }
            }) {
                Text("Log In with Web3Auth")
            }
            .font(.system(size: 30, weight: .bold))
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding(48)
        .navigationDestination(isPresented: $viewModel.isLoggedIn) {
            let viewModel = LobbyViewModel(web3AuthService: viewModel.web3AuthService, dartBoardService: viewModel.dartBoardService)
            LobbyScreen(viewModel: viewModel)
        }
    }
}

//#Preview {
//    let viewModel = LogInViewModel(web3AuthService: Web3AuthService())
//    return LogInScreen(viewModel: viewModel)
//}

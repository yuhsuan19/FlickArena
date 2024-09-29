//
//  PrepareGameViewModel.swift
//  FlickArena
//
//  Created by Shane Chi on 2024/9/8.
//

import Foundation
import web3
import Combine
import CoreImage
import UIKit
import CoreImage.CIFilterBuiltins

final class WaitPlayersViewModel: ObservableObject {

    let aptosClientService: AptosClientService
    let dartBoardService: DartBoardService

    let gameContractAddress: String
    let player1Address: String
    @Published var player2Address: String?
    @Published var canStartGame: Bool = false
    private var cancellables = Set<AnyCancellable>()

    init(aptosClientService: AptosClientService, dartBoardService: DartBoardService, gameContractAddress: String, player2Address: String? = nil) {
        self.aptosClientService = aptosClientService
        self.dartBoardService = dartBoardService

        self.gameContractAddress = gameContractAddress
        self.player2Address = player2Address
        self.player1Address = aptosClientService.account.accountAddress.toString()
        setUpBindings()
    }

    func getPlayer2() {
        Task {
            await aptosClientService.getPlayer2(contractAddress: gameContractAddress)
        }
    }

    func setUpBindings() {
        aptosClientService.secondPlayerAddressSubject
            .sink { [weak self] address in
                DispatchQueue.main.async {
                    self?.player2Address = address
                    self?.canStartGame = true
                }
            }
            .store(in: &cancellables)
    }

    func generateQRCode(from string: String) -> UIImage {
            let context = CIContext()
            let filter = CIFilter.qrCodeGenerator()

            filter.message = Data(string.utf8)
            filter.correctionLevel = "M"

            if let outputImage = filter.outputImage {
                if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                    return UIImage(cgImage: cgimg)
                }
            }

            return UIImage(systemName: "xmark.circle") ?? UIImage()
        }

}

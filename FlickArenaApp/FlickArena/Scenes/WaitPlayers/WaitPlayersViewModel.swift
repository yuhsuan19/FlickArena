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

    let dartGameService: AptosDartGameService
    let dartBoardService: DartBoardService
    let player1Address: String?
    
    var gameContractAddress: String { dartGameService.gameContractAddress }

    @Published var player2Address: String?
    @Published var canStartGame: Bool = false

    init(
        dartGameService: AptosDartGameService,
        dartBoardService: DartBoardService
    ) {
        self.dartGameService = dartGameService
        self.dartBoardService = dartBoardService
        self.player1Address = dartGameService.player1Address
    }

    func startPollingPlayer2() {
        Task {
            do {
                try await Task.sleep(nanoseconds: 1_000_000_000)
                if let address = await dartGameService.pollingPlayer2() {
                    DispatchQueue.main.async { [ weak self] in
                        self?.player2Address = address
                        self?.canStartGame = true
                    }
                }
            }
        }
    }

    func generateGameContractQRCode() -> UIImage {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()

        filter.message = Data(dartGameService.gameContractAddress.utf8)
        filter.correctionLevel = "M"

        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }

        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}

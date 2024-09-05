//
//  ZeroOneGameViewModel.swift
//  FlickArena
//
//  Created by Shane Chi on 2024/9/5.
//

import Foundation
import Combine

final class ZeroOneGameViewModel: ObservableObject {
    
    private let dartBoardService: DartBoardService

    private var cancellables = Set<AnyCancellable>()

    init(dartBoardService: DartBoardService) {
        self.dartBoardService = dartBoardService

        setUpBindings()
    }
}

// MARK: - Private functions
extension ZeroOneGameViewModel {
    private func setUpBindings() {
        dartBoardService.signalSubject
            .sink { signal in
                print(signal)
            }
            .store(in: &cancellables)
    }
}

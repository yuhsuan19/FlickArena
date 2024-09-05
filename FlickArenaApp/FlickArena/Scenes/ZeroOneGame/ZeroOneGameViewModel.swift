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

    private let gameStartScore = 301
    private let totalRounds = 10
    private var maxRound: Int { totalRounds - 1 }

    private let players: [GamePlayer] = [GamePlayer(name: "Dawson"), GamePlayer(name: "Shane")]
    private var currentPlayer: GamePlayer { players[currentPlayerIndex] }

    @Published var currentPlayerIndex: Int = 0
    @Published var currentRound: Int = 0
    @Published var currentScores: [GamePlayer: Int] = [:]
    @Published var gameRecords: [GamePlayer: [[(Int, DartBoardScoreAreaType)]]] = [:]

    private var currentPlayerScore: Int {
        guard let score = currentScores[currentPlayer] else {
            fatalError("Fail to get score of current player")
        }
        return score
    }
    var displayedScore: String {
        return "\(currentPlayerScore)"
    }

    private var currentPlayerCurrentRoundRecords: [(Int, DartBoardScoreAreaType)] {
        guard let records = gameRecords[currentPlayer]?[currentRound] else {
            fatalError("Fail to get the record of the current player in current round")
        }
        return records
    }

    init(dartBoardService: DartBoardService) {
        self.dartBoardService = dartBoardService

        setUpBindings()
        resetGame()
    }
}

// MARK: - Private functions
extension ZeroOneGameViewModel {
    private func setUpBindings() {
        dartBoardService.signalSubject
            .dropFirst()
            .sink { [weak self] signal in
                switch signal {
                case .changePlayer:
                    self?.switchPlayer()
                case let .dartOn(score, type):
                    self?.score(basedScore: score, type: type)
                }
            }
            .store(in: &cancellables)
    }

    private func resetGame() {
        currentPlayerIndex = 0
        currentRound = 0

        currentScores.removeAll()
        players.forEach {
            currentScores[$0] = gameStartScore
        }
        gameRecords.removeAll()
        players.forEach {
            gameRecords[$0] = [[]]
        }
    }

    private func score(basedScore: Int, type: DartBoardScoreAreaType) {
        var scoreToRecord = basedScore
        switch type {
        case .bull:
            scoreToRecord = 50
        case .double:
            scoreToRecord *= 2
        case .triple:
            scoreToRecord *= 3
        case .innerSingle, .outerSingle:
            break
        }
        
        let newScore = currentPlayerScore - scoreToRecord
        guard newScore >= 0 else {
            print("BUST")
            switchPlayer()
            return
        }
        
        currentScores[currentPlayer] = newScore
        var records = currentPlayerCurrentRoundRecords
        records.append((basedScore, type))
        gameRecords[currentPlayer]?[currentRound] = records

        print(currentPlayer)
        print(currentScores)
        print(gameRecords)

        if newScore == 0 {
            decideWinner()
        } else if records.count == 3 {
            switchPlayer()
        }
    }

    private func switchPlayer() {
        guard players.count > 1 else {
            nextRound()
            return
        }

        if currentPlayerIndex == players.count - 1 {
            currentPlayerIndex = 0
            nextRound()
        } else {
            currentPlayerIndex += 1
        }
    }

    private func nextRound() {
        guard currentRound <= maxRound else {
            decideWinner()
            return
        }
        currentRound += 1
        players.forEach {
            gameRecords[$0]?.append([])
        }
    }

    private func decideWinner() {
        var winner = players[0]

        players.forEach() {
            if let score = currentScores[$0], 
                let winnerScore = currentScores[winner],
                score < winnerScore {
                winner = $0
            }
        }
        print("The winner is: \(winner)")
    }
}

//
//  ZeroOneGameViewModel.swift
//  FlickArena
//
//  Created by Shane Chi on 2024/9/5.
//

import Foundation
import Combine
import web3
import BigInt

final class ZeroOneGameViewModel: ObservableObject {

    let dartBoardService: DartBoardService
    let rpcService: RPCService
    let gameContractAddress: String

    private var cancellables = Set<AnyCancellable>()

    private let gameStartScore = 301
    private let totalRounds = 10
    private var maxRound: Int { totalRounds - 1 }

    let players: [GamePlayer]
    private var currentPlayer: GamePlayer { players[currentPlayerIndex] }

    var playerDisplayModels: [ZeroOneGamePlayerDisplayModel] {
        players.map { ZeroOneGamePlayerDisplayModel(playerName: $0.name, currentScore: "\(currentScores[$0] ?? gameStartScore)") }
    }

    @Published var currentPlayerIndex: Int = 0
    @Published var currentRound: Int = 0
    @Published var currentScores: [GamePlayer: Int] = [:]
    private var lastRoundScores: [GamePlayer: Int] = [:]
    @Published var gameRecords: [GamePlayer: [[(Int, DartBoardScoreAreaType)]]] = [:]

    @Published var winner: GamePlayer?

    private var currentPlayerScore: Int {
        guard let score = currentScores[currentPlayer] else {
            fatalError("Fail to get score of current player")
        }
        return score
    }

    private var currentPlayerCurrentRoundRecords: [(Int, DartBoardScoreAreaType)] {
        guard let records = gameRecords[currentPlayer]?[currentRound] else {
            fatalError("Fail to get the record of the current player in current round")
        }
        return records
    }

    init(dartBoardService: DartBoardService, rpcService: RPCService, players: [GamePlayer], gameContractAddress: String) {
        self.players = players
        self.rpcService = rpcService
        self.dartBoardService = dartBoardService
        self.gameContractAddress = gameContractAddress

        setUpBindings()
        resetGame()
    }
}

// MARK: - Private functions
extension ZeroOneGameViewModel {
    private func setUpBindings() {
        dartBoardService.signalSubject
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
        lastRoundScores = currentScores

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

        let scoreToSend = scoreToRecord
        Task {
            await rpcService.dartOn(
                gameContract: EthereumAddress(stringLiteral: gameContractAddress),
                player: EthereumAddress(stringLiteral: currentPlayer.address),
                score: scoreToSend
            )
        }

        let newScore = currentPlayerScore - scoreToRecord
        guard newScore >= 0 else {
            print("BUST")
            currentScores[currentPlayer] = lastRoundScores[currentPlayer]
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
            lastRoundScores[currentPlayer] = newScore
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
        guard currentRound < maxRound else {
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

        self.winner = winner
    }
}

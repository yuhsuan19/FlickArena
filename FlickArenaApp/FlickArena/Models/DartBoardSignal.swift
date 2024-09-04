//
//  DartBoardSignal.swift
//  FlickArena
//
//  Created by Shane Chi on 2024/9/4.
//

import Foundation

enum DartBoardSignal {
    case changePlayer
    case dartOn(score: Int, type: DartBoardScoreAreaType)
}

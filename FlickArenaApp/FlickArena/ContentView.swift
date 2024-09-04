//
//  ContentView.swift
//  FlickArena
//
//  Created by Shane Chi on 2024/9/4.
//

import SwiftUI
import CoreBluetooth

struct ContentView: View {
    @StateObject var dartBoardService: DartBoardService = DartBoardService(centralManager: CBCentralManager())

    var text: String {
        switch dartBoardService.dartBoardSignal {
        case .changePlayer:
            return "Change Player"
        case let .dartOn(score, type):
            return "\(score), \(type)"
        default:
            return "-"
        }
    }

    var body: some View {
        VStack {
            Text(text)
                .fontWeight(.heavy)
                .font(.system(size: 100))
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

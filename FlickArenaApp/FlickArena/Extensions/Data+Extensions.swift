//
//  Data+Extensions.swift
//  FlickArena
//
//  Created by Shane Chi on 2024/9/4.
//

import Foundation

extension Data {
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}

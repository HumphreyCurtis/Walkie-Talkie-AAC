//
//  CommunicationSymbol.swift
//  Walkie Talkie AAC
//
//  One curated symbol from the Mulberry set, used by both the Symbol Library
//  browse screen and the speech-driven word-matcher.
//

import Foundation

struct CommunicationSymbol: Identifiable, Hashable, Codable {
    let id: String
    let assetName: String
    let displayLabel: String
    let category: String
    let rawCategory: String
}

extension CommunicationSymbol {
    static func titleCased(_ word: String) -> String {
        word.split(separator: "_")
            .map { $0.prefix(1).uppercased() + $0.dropFirst() }
            .joined(separator: " ")
    }
}
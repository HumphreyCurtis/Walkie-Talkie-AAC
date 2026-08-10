//
//  SymbolLibrary.swift
//  Walkie Talkie AAC
//
//  Maps a spoken word onto a symbol from the bundled picture set.
//
//  The symbols are the abstracted, standardised kind found on public signage
//  — the wheelchair pictogram, the tortoise for "slowly" — rather than
//  illustrations. That abstraction is what makes them readable by a stranger
//  at a glance, which is the whole job.
//
//  Phase 4: Now data-driven from Resources/Mulberry/word-map.json instead
//  of hardcoded entries, with a small supplementary synonym table for
//  genuine aliases the automated mapping cannot know about.
//  Phase 5: Also exposes the full symbol list, categories, and search for
//  the Symbol Library browse screen.
//

import Foundation
import SwiftUI

enum SymbolLibrary {
    // MARK: - Word lookup (Phase 4, Symbol Speak)

    /// Word → asset name from the curated Mulberry symbol set.
    private static let wordMap: [String: String] = embeddedWordMap

    /// Hand-picked synonyms the automated mapping cannot know about.
    private static let synonyms: [String: String] = [
        "stroke": "aphasia",
        "flower": "sunflower",
        "seat": "chair",
        "sit": "chair",
        "sitting": "chair",
        "tea": "coffee",
        "cup": "coffee",
        "americano": "coffee",
        "cappuccino": "coffee",
        "latte": "coffee",
        "helping": "help",
        "confused": "lost",
        "loo": "toilet",
        "bathroom": "toilet",
        "restroom": "toilet",
    ]

    /// The asset name for a spoken word, or nil if nothing matches.
    static func assetName(for word: String) -> String? {
        let cleaned = word
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: .punctuationCharacters)
            .lowercased()

        guard !cleaned.isEmpty else { return nil }

        if let match = wordMap[cleaned] ?? synonyms[cleaned] { return match }

        if cleaned.hasSuffix("s") {
            let singular = String(cleaned.dropLast())
            if let match = wordMap[singular] ?? synonyms[singular] { return match }
        }

        return nil
    }

    /// A fallback SF Symbol for words with no picture.
    static let fallbackSystemIcon = "text.bubble.fill"

    // MARK: - Symbol Library (Phase 5)

    private static let _allSymbols: [CommunicationSymbol] = embeddedSymbols

    static var allSymbols: [CommunicationSymbol] { _allSymbols }

    static var categories: [SymbolCategory] {
        var grouped: [String: [CommunicationSymbol]] = [:]
        for symbol in _allSymbols {
            let key = categoryGroup(for: symbol.rawCategory)
            grouped[key, default: []].append(symbol)
        }
        return grouped.keys.sorted().map { name in
            SymbolCategory(name: name, symbols: grouped[name] ?? [])
        }
    }

    static func search(query: String) -> [CommunicationSymbol] {
        let q = query.lowercased().trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty else { return _allSymbols }
        return _allSymbols.filter {
            $0.displayLabel.lowercased().contains(q) ||
            $0.rawCategory.lowercased().contains(q)
        }
    }

    // MARK: - Category grouping

    private static func categoryGroup(for raw: String) -> String {
        if raw == "Country Flags" || raw == "Country Maps" { return "Countries" }
        if raw == "Verb" { return "Actions" }
        if raw.hasPrefix("Food") || raw.hasPrefix("Drink") { return "Food & Drink" }
        if raw.hasPrefix("Healthcare") { return "Body & Health" }
        if raw.hasPrefix("Animal") || raw == "Plants and Trees" || raw == "Environment Weather" { return "Animals & Nature" }
        if raw.hasPrefix("Descriptive") || raw == "Question" || raw == "People Feelings" { return "Feelings & Descriptions" }
        if raw.hasPrefix("People") || raw.hasPrefix("Building") || raw.hasPrefix("Religion") || raw == "Holiday and travel" || raw == "Politics" || raw == "Military" { return "People & Places" }
        if raw.hasPrefix("Clothes") || raw.hasPrefix("Transport") || raw.hasPrefix("Tools") || raw.hasPrefix("Electrical") || raw.hasPrefix("Computer") || raw == "Music Instrument" || raw.hasPrefix("Art") || raw.hasPrefix("Sport") || raw.hasPrefix("Leisure") || raw == "Money" { return "Everyday Objects" }
        if raw.hasPrefix("Communication") || raw == "Number" || raw == "Number Activity" { return "Communication" }
        if raw.hasPrefix("Celebration") { return "Celebrations" }
        if raw.hasPrefix("Science") { return "Science & Learning" }
        if raw.hasPrefix("Work") { return "Work & School" }
        return "Other"
    }

    // MARK: - CSV parsing

    private static func parseCSV(_ data: String) -> [CommunicationSymbol] {
        var symbols: [CommunicationSymbol] = []
        let lines = data.split(separator: "\n", omittingEmptySubsequences: true)
        guard lines.count > 1 else { return [] }
        for line in lines.dropFirst() {
            let parts = line.split(separator: ",", maxSplits: 4, omittingEmptySubsequences: false)
            guard parts.count >= 5 else { continue }
            let word = String(parts[0]).trimmingCharacters(in: .whitespaces)
            let rawCat = String(parts[4]).trimmingCharacters(in: .whitespaces)
            let sym = CommunicationSymbol(
                id: word,
                assetName: word,
                displayLabel: symbolLabel(for: word),
                category: categoryGroup(for: rawCat),
                rawCategory: rawCat
            )
            symbols.append(sym)
        }
        return symbols
    }

    private static func symbolLabel(for word: String) -> String {
        word.split(separator: "_")
            .map { $0.prefix(1).uppercased() + $0.dropFirst() }
            .joined(separator: " ")
    }
}

struct SymbolCategory: Identifiable {
    let id: String
    let name: String
    let symbols: [CommunicationSymbol]

    init(name: String, symbols: [CommunicationSymbol]) {
        self.id = name
        self.name = name
        self.symbols = symbols
    }
}
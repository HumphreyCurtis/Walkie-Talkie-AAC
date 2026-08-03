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

import Foundation
import SwiftUI

enum SymbolLibrary {
    /// Words that should resolve to a bundled picture, beyond the asset name
    /// itself. Kept as synonyms rather than as extra image sets so one
    /// picture can answer to everything a person might actually say.
    private static let synonyms: [String: String] = [
        // Expression
        "aphasia": "aphasia",
        "stroke": "aphasia",
        "speak": "speak",
        "speaking": "speak",
        "talk": "speak",
        "talking": "speak",
        "help": "help",
        "helping": "help",
        "assist": "assistance",
        "assistance": "assistance",
        "carer": "assistance",
        "support": "assistance",
        "disabled": "disabled",
        "disability": "disability",
        "wheelchair": "disability",
        "lost": "lost",
        "confused": "lost",
        "thanks": "thanks",
        "thank": "thanks",
        "happy": "thanks",
        "please": "thanks",
        "time": "time",
        "clock": "time",
        "wait": "time",
        "waiting": "time",
        "late": "time",

        // Object
        "chair": "chair",
        "seat": "chair",
        "sit": "chair",
        "sitting": "chair",
        "slow": "slowly",
        "slowly": "slowly",
        "slower": "slowly",
        "tortoise": "slowly",
        "toilet": "toilet",
        "loo": "toilet",
        "bathroom": "toilet",
        "restroom": "toilet",
        "sunflower": "sunflower",
        "flower": "sunflower",

        // Drink
        "coffee": "coffee",
        "tea": "coffee",
        "drink": "coffee",
        "cup": "coffee",
        "americano": "coffee",
        "cappuccino": "coffee",
        "latte": "coffee",
    ]

    /// The asset name for a spoken word, or nil if nothing matches.
    ///
    /// Strips the punctuation the recogniser adds, then tries the word
    /// itself, then its synonyms, then a naive singular.
    static func assetName(for word: String) -> String? {
        let cleaned = word
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: .punctuationCharacters)
            .lowercased()

        guard !cleaned.isEmpty else { return nil }

        if let match = synonyms[cleaned] { return match }

        if cleaned.hasSuffix("s") {
            let singular = String(cleaned.dropLast())
            if let match = synonyms[singular] { return match }
        }

        return nil
    }

    /// A fallback SF Symbol for words with no picture, so the display is
    /// never blank while someone is mid-sentence.
    static let fallbackSystemIcon = "text.bubble.fill"
}

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
        // Photos (not from Mulberry) — preserved during Phase 1 cleanup
        "aphasia": "aphasia",
        "stroke": "aphasia",
        "sunflower": "sunflower",
        "flower": "sunflower",
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

//
//  BadgeTransfer.swift
//  Walkie Talkie AAC
//
//  Getting badges in and out of the app via the clipboard and any language
//  model the user already has — ChatGPT, Claude, Gemini, whatever is on their
//  phone. The app itself makes no network calls and holds no API key.
//
//  The flow is: copy a prompt, paste it into the assistant, paste the reply
//  back, review what changed, save. The user sees the diff before anything is
//  written, because a communication aid that silently rewrites itself is not
//  one the wearer controls.
//
//  Parsing is deliberately forgiving. Assistants wrap JSON in prose and code
//  fences, invent SF Symbol names that do not exist, and use colour words
//  outside the palette. Every one of those is repaired rather than rejected,
//  because a hard failure hands the user a JSON error message they cannot act
//  on.
//

import Foundation
import SwiftUI

enum BadgeTransfer {

    // MARK: - Curated symbols
    //
    // Offered to the assistant so it picks from names that certainly exist.
    // Anything else it returns is repaired at parse time.

    static let suggestedIcons = [
        "text.bubble.fill", "hand.raised.fill", "exclamationmark.triangle.fill",
        "questionmark.circle.fill", "brain.head.profile", "ear.fill",
        "mouth.fill", "eye.fill", "hands.clap.fill", "heart.fill",
        "tortoise.fill", "hare.fill", "clock.fill", "calendar",
        "chair.fill", "bed.double.fill", "fork.knife", "cup.and.saucer.fill",
        "cart.fill", "creditcard.fill", "pills.fill", "cross.case.fill",
        "figure.roll", "figure.walk", "stethoscope", "phone.fill",
        "house.fill", "tram.fill", "bus.fill", "airplane",
        "map.fill", "location.fill", "square.and.pencil", "book.fill",
        "toilet.fill", "waterbottle.fill", "bag.fill", "key.fill",
        "camera.macro", "sun.max.fill", "drop.fill", "checkmark.circle.fill",
    ]

    // MARK: - The prompt

    /// A self-contained prompt describing the schema, the palette and the
    /// symbol set, with the user's current badges attached.
    ///
    /// Self-contained because it is pasted into a fresh chat with no context:
    /// everything the model needs to produce valid output has to be in this
    /// one string.
    static func prompt(for badges: [Badge]) -> String {
        let colours = BadgeColor.names.joined(separator: ", ")
        let icons = suggestedIcons.joined(separator: ", ")
        let current = exportJSON(badges)

        return """
        You are helping someone set up Walkie Talkie AAC, an iPhone app that \
        turns a phone into an outward-facing sign. Each "badge" is one \
        message shown to the person they are talking to in large type, and \
        optionally spoken aloud.

        People use it when speech is difficult, when they communicate in \
        different languages, or when showing words is simply clearer. Write \
        short, plain, respectful sentences in the language requested. Say \
        please and thank you. Write from the wearer's point of view \
        ("Please talk slowly"), never about them.

        Return ONLY a JSON array. No explanation, no markdown fence.

        Each object has:
          "label"        — one or two words, shown in the app's list. Required.
          "displayText"  — the full message shown and spoken. Required.
          "systemIcon"   — an SF Symbol name. Choose from: \(icons)
          "emoji"        — optional; shown instead of the icon when present.
          "colorName"    — one of: \(colours)
          "languageCode" — optional BCP 47 tag, e.g. "fr-FR". Omit for the \
        device language.
          "displayMode"  — "wholeMessage" or "wordByWord". Use \
        "wholeMessage" unless the user asks for words one at a time.
          "textScale"    — optional number from 0.6 to 1.0. Use 1.0 for the \
        largest lettering.

        Here are the badges they have now. Keep the "id" of any you are \
        editing so it updates rather than duplicating; omit "id" for new ones.

        \(current)
        """
    }

    /// A pretty-printed array, for the JSON editor and for the prompt.
    static func exportJSON(_ badges: [Badge]) -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(badges),
              let string = String(data: data, encoding: .utf8)
        else { return "[]" }
        return string
    }

    // MARK: - Parsing

    enum ParseError: LocalizedError {
        case noJSONFound
        case notAnArray
        case noValidBadges

        var errorDescription: String? {
            switch self {
            case .noJSONFound:
                return "Could not find any JSON in what you pasted. Copy the assistant's whole reply and try again."
            case .notAnArray:
                return "That JSON is not a list of badges. It should start with [ and end with ]."
            case .noValidBadges:
                return "No badges in that JSON had both a label and a message."
            }
        }
    }

    /// Every field optional, so one malformed entry cannot fail the decode
    /// for the whole array.
    private struct LenientBadge: Decodable {
        var id: UUID?
        var label: String?
        var displayText: String?
        var text: String?          // common alternative the models produce
        var spokenText: String?    // ditto, and matches the sibling watch app
        var systemIcon: String?
        var icon: String?
        var emoji: String?
        var colorName: String?
        var color: String?
        var languageCode: String?
        var displayMode: String?
        var textScale: Double?
        var backgroundImageName: String?
    }

    static func parse(_ raw: String) throws -> [Badge] {
        guard let json = extractJSON(from: raw) else { throw ParseError.noJSONFound }
        guard let data = json.data(using: .utf8) else { throw ParseError.noJSONFound }

        let lenient: [LenientBadge]
        do {
            lenient = try JSONDecoder().decode([LenientBadge].self, from: data)
        } catch {
            throw ParseError.notAnArray
        }

        let badges = lenient.compactMap { repair($0) }
        guard !badges.isEmpty else { throw ParseError.noValidBadges }
        return badges
    }

    /// Turns a loosely-shaped object into a valid badge, or discards it if
    /// there is no message in it at all.
    private static func repair(_ raw: LenientBadge) -> Badge? {
        let message = [raw.displayText, raw.spokenText, raw.text]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .first { !$0.isEmpty }

        guard let message else { return nil }

        // A missing label is recoverable — take the first two words of the
        // message. A missing message is not.
        let label = raw.label?.trimmingCharacters(in: .whitespacesAndNewlines)
        let resolvedLabel: String = {
            if let label, !label.isEmpty { return label }
            return message.split(separator: " ").prefix(2).joined(separator: " ")
        }()

        let icon = [raw.systemIcon, raw.icon].compactMap { $0 }.first { !$0.isEmpty }
        let resolvedIcon: String = {
            guard let icon else { return "text.bubble.fill" }
            // Models confidently invent symbol names. Verify against the
            // system rather than trusting the string.
            return UIImage(systemName: icon) != nil ? icon : "text.bubble.fill"
        }()

        let colour = [raw.colorName, raw.color].compactMap { $0?.lowercased() }.first
        let resolvedColour: String? = {
            guard let colour else { return nil }
            if BadgeColor.names.contains(colour) { return colour }
            // Map the near-misses rather than dropping to the default.
            switch colour {
            case "yellow", "gold": return "amber"
            case "indigo", "violet", "magenta", "pink": return "purple"
            case "cyan", "turquoise": return "teal"
            case "tan", "beige": return "brown"
            default: return nil
            }
        }()

        let emoji = raw.emoji?.trimmingCharacters(in: .whitespacesAndNewlines)
        let displayMode: BadgeDisplayMode = {
            switch raw.displayMode?.lowercased() {
            case "wordbyword", "word-by-word", "onewordatatime", "one word at a time":
                return .wordByWord
            default:
                return .wholeMessage
            }
        }()

        return Badge(
            id: raw.id ?? UUID(),
            label: resolvedLabel,
            displayText: message,
            systemIcon: resolvedIcon,
            emoji: (emoji?.isEmpty ?? true) ? nil : emoji,
            colorName: resolvedColour,
            languageCode: raw.languageCode,
            displayMode: displayMode,
            textScale: raw.textScale ?? 1,
            backgroundImageName: raw.backgroundImageName
        )
    }

    /// Pulls the first balanced JSON array out of arbitrary text.
    ///
    /// Brace-counting rather than a regex, and string-aware, so a `]` inside
    /// a message ("Press [OK]") does not truncate the array. Handles the
    /// prose and code fences that assistants wrap replies in.
    static func extractJSON(from raw: String) -> String? {
        guard let start = raw.firstIndex(of: "[") else { return nil }

        var depth = 0
        var insideString = false
        var escaped = false

        for index in raw.indices[start...] {
            let character = raw[index]

            if escaped {
                escaped = false
                continue
            }
            if character == "\\" && insideString {
                escaped = true
                continue
            }
            if character == "\"" {
                insideString.toggle()
                continue
            }
            guard !insideString else { continue }

            if character == "[" {
                depth += 1
            } else if character == "]" {
                depth -= 1
                if depth == 0 {
                    return String(raw[start...index])
                }
            }
        }

        return nil
    }

    // MARK: - Merging

    enum ChangeKind {
        case added, updated, unchanged
    }

    struct Change: Identifiable {
        let id = UUID()
        let badge: Badge
        let kind: ChangeKind
    }

    /// Matches incoming badges against existing ones by id first, then by
    /// case-insensitive label, and reports what would change.
    ///
    /// Returns the changes rather than applying them so the user can see the
    /// diff and decide.
    static func merge(incoming: [Badge], into existing: [Badge]) -> (result: [Badge], changes: [Change]) {
        var result = existing
        var changes: [Change] = []

        for var badge in incoming {
            let matchIndex = result.firstIndex { $0.id == badge.id }
                ?? result.firstIndex { $0.label.lowercased() == badge.label.lowercased() }

            if let matchIndex {
                // Keep the existing id so the update lands on the same badge
                // even when the assistant dropped it. The AI prompt does not
                // expose local photo filenames, so an edit must also retain
                // the badge's existing background photo.
                badge.id = result[matchIndex].id
                badge.backgroundImageName = result[matchIndex].backgroundImageName
                if result[matchIndex] == badge {
                    changes.append(Change(badge: badge, kind: .unchanged))
                } else {
                    result[matchIndex] = badge
                    changes.append(Change(badge: badge, kind: .updated))
                }
            } else {
                result.append(badge)
                changes.append(Change(badge: badge, kind: .added))
            }
        }

        return (result, changes)
    }
}

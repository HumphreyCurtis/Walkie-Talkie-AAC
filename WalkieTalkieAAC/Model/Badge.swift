//
//  Badge.swift
//  Walkie Talkie AAC
//
//  A badge is one outward-facing message: what it says, what it looks like,
//  and what it sounds like if the wearer chooses to speak it.
//
//  The default set comes from the phrases co-designers wrote in the study
//  workshops, kept close to their own wording. Politeness was a repeated
//  requirement — "Manners! You know!" — so the requests say please.
//

import Foundation

struct Badge: Identifiable, Codable, Hashable {
    var id = UUID()

    /// One or two words. What the wearer scans for in the list.
    var label: String

    /// The full message shown outward and spoken aloud. Shown one word at a
    /// time at display size, so length is not a problem.
    var displayText: String

    /// SF Symbol name, shown when `emoji` is empty.
    var systemIcon: String

    /// Shown instead of `systemIcon` when set.
    var emoji: String?

    /// One of `BadgeColor.names`. `nil` means motorway blue.
    var colorName: String?

    /// BCP 47 tag. `nil` follows the device language.
    var languageCode: String?

    init(
        id: UUID = UUID(),
        label: String,
        displayText: String,
        systemIcon: String = "text.bubble.fill",
        emoji: String? = nil,
        colorName: String? = nil,
        languageCode: String? = nil
    ) {
        self.id = id
        self.label = label
        self.displayText = displayText
        self.systemIcon = systemIcon
        self.emoji = emoji
        self.colorName = colorName
        self.languageCode = languageCode
    }
}

enum BadgeLibrary {
    /// The hidden-disability badge. Kept separate because showing it is an
    /// explicit opt-in rather than a badge like any other.
    static let sunflowerIcon = "camera.macro"

    static let defaults: [Badge] = [
        Badge(
            label: "Help",
            displayText: "Please can you help me?",
            systemIcon: "hand.raised.fill",
            colorName: "red"
        ),
        Badge(
            label: "Stroke",
            displayText: "I have had a stroke and aphasia.",
            systemIcon: "brain.head.profile",
            colorName: "blue"
        ),
        Badge(
            label: "Slower",
            displayText: "Please talk slowly. Do not finish my words.",
            systemIcon: "tortoise.fill",
            colorName: "green"
        ),
        Badge(
            label: "Seat",
            displayText: "Could you please let me have your seat? Many thanks!",
            systemIcon: "chair.fill",
            colorName: "amber"
        ),
        Badge(
            label: "Time",
            displayText: "Please give me time to speak.",
            systemIcon: "clock.fill",
            colorName: "purple"
        ),
        Badge(
            label: "Write",
            displayText: "Please can you write this down?",
            systemIcon: "square.and.pencil",
            colorName: "teal"
        ),
        Badge(
            label: "Disability",
            displayText: "I have an invisible disability.",
            systemIcon: "figure.roll",
            colorName: "brown"
        ),
        Badge(
            label: "Toilet",
            displayText: "Where is the toilet please?",
            systemIcon: "toilet.fill",
            colorName: "orange"
        ),
        Badge(
            label: "Thanks",
            displayText: "Thank you very much!",
            systemIcon: "hands.clap.fill",
            colorName: "green"
        ),
    ]

    /// Added at seed version 2. Non-English examples, to make it obvious in
    /// the editor that a badge can carry its own language.
    static let multilingualExamples: [Badge] = [
        Badge(
            label: "Perdu",
            displayText: "Je suis perdu. Pouvez-vous m'aider ?",
            systemIcon: "map.fill",
            emoji: "🇫🇷",
            colorName: "blue",
            languageCode: "fr-FR"
        ),
        Badge(
            label: "Metro",
            displayText: "¿Dónde está el metro, por favor?",
            systemIcon: "tram.fill",
            emoji: "🇪🇸",
            colorName: "red",
            languageCode: "es-ES"
        ),
    ]
}

enum SettingsKeys {
    static let prefersFemaleVoice = "prefersFemaleVoice"
    static let speechRate = "speechRate"
    static let wordInterval = "wordInterval"
    static let showsSunflowerBadge = "showsSunflowerBadge"
    static let facesOutward = "facesOutward"
}

/// How long each word sits on screen in the word-by-word display.
///
/// Participants asked for control over this in both directions — "too quick!"
/// from some, faster from others — so it is a setting rather than a constant.
enum WordPace {
    static let `default`: Double = 0.5
    static let slowest: Double = 1.5
    static let fastest: Double = 0.3

    /// Read live from UserDefaults and clamped, so a bad stored value or an
    /// unset key can never stall the display.
    static var current: Double {
        let stored = UserDefaults.standard.double(forKey: SettingsKeys.wordInterval)
        guard stored > 0 else { return `default` }
        return min(max(stored, fastest), slowest)
    }
}

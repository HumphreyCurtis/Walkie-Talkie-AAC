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

enum BadgeDisplayMode: String, Codable, CaseIterable, Hashable {
    case wholeMessage
    case wordByWord

    var title: String {
        switch self {
        case .wholeMessage: "Whole message"
        case .wordByWord: "One word at a time"
        }
    }
}

struct Badge: Identifiable, Codable, Hashable {
    var id = UUID()

    /// One or two words. What the wearer scans for in the list.
    var label: String

    /// The full message shown outward and spoken aloud. The badge decides
    /// whether it stays whole or advances one word at a time.
    var displayText: String

    /// SF Symbol name, shown when `emoji` is empty.
    var systemIcon: String

    /// Shown instead of `systemIcon` when set.
    var emoji: String?

    /// One of `BadgeColor.names`. `nil` means motorway blue.
    var colorName: String?

    /// BCP 47 tag. `nil` follows the device language.
    var languageCode: String?

    /// How the outward-facing message is presented.
    var displayMode: BadgeDisplayMode

    /// A multiplier applied after the display has found the largest fitting
    /// type size. One is the largest safe size; smaller values leave more air.
    var textScale: Double

    /// Filename of a photo used as the badge's background, stored alongside
    /// `Badges.json`. `nil` means the badge shows its colour.
    ///
    /// Co-designers used this to camouflage — one held the phone against a
    /// striped shirt so the badge disappeared into what he was wearing. Being
    /// able to make the device invisible matters as much as making it shout.
    var backgroundImageName: String?

    init(
        id: UUID = UUID(),
        label: String,
        displayText: String,
        systemIcon: String = "text.bubble.fill",
        emoji: String? = nil,
        colorName: String? = nil,
        languageCode: String? = nil,
        displayMode: BadgeDisplayMode = .wholeMessage,
        textScale: Double = 1,
        backgroundImageName: String? = nil
    ) {
        self.id = id
        self.label = label
        self.displayText = displayText
        self.systemIcon = systemIcon
        self.emoji = emoji
        self.colorName = colorName
        self.languageCode = languageCode
        self.displayMode = displayMode
        self.textScale = min(max(textScale, 0.6), 1)
        self.backgroundImageName = backgroundImageName
    }

    private enum CodingKeys: String, CodingKey {
        case id, label, displayText, systemIcon, emoji, colorName
        case languageCode, displayMode, textScale, backgroundImageName
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        label = try values.decode(String.self, forKey: .label)
        displayText = try values.decode(String.self, forKey: .displayText)
        systemIcon = try values.decodeIfPresent(String.self, forKey: .systemIcon) ?? "text.bubble.fill"
        emoji = try values.decodeIfPresent(String.self, forKey: .emoji)
        colorName = try values.decodeIfPresent(String.self, forKey: .colorName)
        languageCode = try values.decodeIfPresent(String.self, forKey: .languageCode)
        displayMode = try values.decodeIfPresent(BadgeDisplayMode.self, forKey: .displayMode) ?? .wholeMessage
        textScale = min(max(try values.decodeIfPresent(Double.self, forKey: .textScale) ?? 1, 0.6), 1)
        backgroundImageName = try values.decodeIfPresent(String.self, forKey: .backgroundImageName)
    }
}

enum BadgeLibrary {
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
            label: "Seat",
            displayText: "Could you please let me have your seat? Many thanks!",
            systemIcon: "chair.fill",
            colorName: "amber"
        ),
        Badge(
            label: "Disability",
            displayText: "I have an invisible disability.",
            systemIcon: "figure.roll",
            colorName: "brown"
        ),
        Badge(
            label: "Thanks",
            displayText: "Thank you very much!",
            systemIcon: "hands.clap.fill",
            colorName: "green"
        ),
        Badge(
            label: "Toilet",
            displayText: "Where is the toilet please?",
            systemIcon: "toilet.fill",
            colorName: "orange"
        ),
        Badge(
            label: "Water",
            displayText: "Can I have a glass of water please?",
            systemIcon: "drop.fill",
            colorName: "blue"
        ),
        Badge(
            label: "In Pain",
            displayText: "I am in pain. Please help me.",
            systemIcon: "heart.circle.fill",
            colorName: "red"
        ),
        Badge(
            label: "Doctor",
            displayText: "Please call a doctor.",
            systemIcon: "stethoscope",
            colorName: "orange"
        ),
        Badge(
            label: "Home",
            displayText: "I want to go home please.",
            systemIcon: "house.fill",
            colorName: "green"
        )
    ]

    /// Starting badges that used to ship and no longer do, as
    /// (label, message) pairs.
    ///
    /// Kept verbatim so an install made before the set was trimmed can drop
    /// them. A badge only matches if both its label and its message are
    /// untouched, so anything the user edited or wrote themselves survives.
    static let retiredDefaults: [(String, String)] = [
        ("Sad", "I feel sad today."),
        ("Happy", "I am happy!"),
        ("Hungry", "I am hungry. Can I have something to eat please?"),
        ("Tired", "I am tired. I need a rest."),
        ("Scared", "I am scared. Please stay with me."),
        ("Calm", "Please stay calm. Everything will be okay."),
        ("Medicine", "I need my medicine please."),
        ("Cold", "I am cold. Can I have a blanket please?"),
        ("Hot", "I am too hot. Can you open a window please?"),
        ("Stop", "Please stop. I need a break."),
        ("Love", "I love you."),
        ("Sorry", "I am sorry."),
        ("Yes", "Yes please."),
        ("No", "No thank you."),
        ("Hurt", "I hurt myself. Help me please."),
        // The second of two Toilet entries that shipped by mistake.
        ("Toilet", "I need the toilet please."),
        ("Metro", "¿Dónde está el metro, por favor?"),
    ]

    static let sunflower = Badge(
        label: "Sunflower",
        displayText: "Please be patient with me.",
        systemIcon: "camera.macro",
        emoji: "🌻",
        colorName: "green"
    )

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
    ]
}

enum SettingsKeys {
    static let prefersFemaleVoice = "prefersFemaleVoice"
    static let speechRate = "speechRate"
    static let wordInterval = "wordInterval"
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

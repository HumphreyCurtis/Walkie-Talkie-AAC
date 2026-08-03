//
//  SettingsStore.swift
//  Walkie Talkie AAC
//
//  Four preferences, mirrored into UserDefaults so that views can read them
//  with @AppStorage and non-view code (Speaker, WordPace) can read them
//  directly without holding a reference to the store.
//

import Foundation
import Observation

@Observable
final class SettingsStore {
    static let shared = SettingsStore()

    var prefersFemaleVoice: Bool {
        didSet { defaults.set(prefersFemaleVoice, forKey: SettingsKeys.prefersFemaleVoice) }
    }

    var speechRate: Double {
        didSet { defaults.set(speechRate, forKey: SettingsKeys.speechRate) }
    }

    var wordInterval: Double {
        didSet { defaults.set(wordInterval, forKey: SettingsKeys.wordInterval) }
    }

    /// Whether the hidden-disability badge appears on display views.
    ///
    /// Off by default, and it stays that way. Disclosing a disability to a
    /// carriage full of strangers is the wearer's decision to make
    /// deliberately, not something an app should switch on for them.
    var showsSunflowerBadge: Bool {
        didSet { defaults.set(showsSunflowerBadge, forKey: SettingsKeys.showsSunflowerBadge) }
    }

    /// Whether badges open rotated 180° to face the person opposite.
    ///
    /// On by default: the phone is worn on a lanyard with the screen facing
    /// out, so "the right way up" is upside down from the wearer's view.
    var facesOutward: Bool {
        didSet { defaults.set(facesOutward, forKey: SettingsKeys.facesOutward) }
    }

    private let defaults = UserDefaults.standard

    private init() {
        defaults.register(defaults: [
            SettingsKeys.speechRate: Speaker.defaultRate,
            SettingsKeys.wordInterval: WordPace.default,
            SettingsKeys.facesOutward: true,
            SettingsKeys.showsSunflowerBadge: false,
        ])

        prefersFemaleVoice = defaults.bool(forKey: SettingsKeys.prefersFemaleVoice)
        speechRate = defaults.double(forKey: SettingsKeys.speechRate)
        wordInterval = defaults.double(forKey: SettingsKeys.wordInterval)
        showsSunflowerBadge = defaults.bool(forKey: SettingsKeys.showsSunflowerBadge)
        facesOutward = defaults.bool(forKey: SettingsKeys.facesOutward)
    }
}

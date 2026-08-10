//
//  SettingsStore.swift
//  Walkie Talkie AAC
//
//  Preferences mirrored into UserDefaults so that views can read them
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
        ])

        prefersFemaleVoice = defaults.bool(forKey: SettingsKeys.prefersFemaleVoice)
        speechRate = defaults.double(forKey: SettingsKeys.speechRate)
        wordInterval = defaults.double(forKey: SettingsKeys.wordInterval)
        facesOutward = defaults.bool(forKey: SettingsKeys.facesOutward)
    }
}

//
//  Speaker.swift
//  Walkie Talkie AAC
//
//  One long-lived synthesiser for the whole app.
//
//  A singleton rather than a `@State` property per view, because a
//  view-owned AVSpeechSynthesizer gets deallocated when the view goes away
//  and cuts the sentence off mid-word. The old code had three separate
//  copies of this and hit exactly that.
//
//  Speech is the option, not the point. The study was explicit that these
//  devices should scaffold someone's own communication rather than replace
//  their voice with a synthetic one — across the observed sessions, speech
//  output was used far less than the display itself. So nothing here speaks
//  automatically; every utterance is something the wearer pressed.
//

import AVFoundation

final class Speaker {
    static let shared = Speaker()

    private let synthesizer = AVSpeechSynthesizer()

    static let defaultRate: Float = 0.45
    static let slowestRate: Float = 0.3
    static let fastestRate: Float = 0.6

    private init() {}

    /// Configures the audio session so speech is audible even with the ringer
    /// switch off, and ducks rather than stops whatever else is playing.
    private func activateSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
        try? session.setActive(true)
    }

    func speak(_ text: String, languageCode: String? = nil) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        activateSession()

        // Repeated presses restart rather than queue. Someone pressing twice
        // means "say it again", not "say it twice".
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        let utterance = AVSpeechUtterance(string: trimmed)
        utterance.voice = voice(for: languageCode)
        utterance.rate = currentRate
        utterance.pitchMultiplier = 0.95
        utterance.volume = 1.0
        utterance.postUtteranceDelay = 0.2

        synthesizer.speak(utterance)
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }

    var isSpeaking: Bool { synthesizer.isSpeaking }

    private var currentRate: Float {
        let stored = UserDefaults.standard.float(forKey: SettingsKeys.speechRate)
        guard stored > 0 else { return Self.defaultRate }
        return min(max(stored, Self.slowestRate), Self.fastestRate)
    }

    private var prefersFemaleVoice: Bool {
        UserDefaults.standard.bool(forKey: SettingsKeys.prefersFemaleVoice)
    }

    /// Picks a voice for a language, honouring the gender preference.
    ///
    /// Matches on the primary language subtag rather than the full locale.
    /// Insisting on an exact "en-GB" match makes the female-voice setting a
    /// no-op, because Daniel is the only en-GB voice installed by default;
    /// widening to "en" finds Samantha and the rest.
    private func voice(for languageCode: String?) -> AVSpeechSynthesisVoice? {
        let requested = languageCode ?? AVSpeechSynthesisVoice.currentLanguageCode()
        let primary = requested.split(separator: "-").first.map(String.init) ?? requested

        let candidates = AVSpeechSynthesisVoice.speechVoices().filter {
            $0.language.hasPrefix(primary)
        }

        let wanted: AVSpeechSynthesisVoiceGender = prefersFemaleVoice ? .female : .male

        // Prefer the requested locale exactly, then the right gender anywhere
        // in the language, then anything in the language.
        if let exact = candidates.first(where: { $0.language == requested && $0.gender == wanted }) {
            return exact
        }
        if let byGender = candidates.first(where: { $0.gender == wanted }) {
            return byGender
        }
        if let byLocale = candidates.first(where: { $0.language == requested }) {
            return byLocale
        }
        // Falling back through the initialiser rather than taking the first
        // candidate avoids landing on a novelty voice.
        return AVSpeechSynthesisVoice(language: requested) ?? candidates.first
    }
}

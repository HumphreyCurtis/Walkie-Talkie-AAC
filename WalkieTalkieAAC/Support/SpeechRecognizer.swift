//
//  SpeechRecognizer.swift
//  Walkie Talkie AAC
//
//  Live transcription for Symbol Speak: the wearer or their partner talks,
//  and the app shows the matching symbol on the outward-facing display.
//
//  Recognition runs on-device where the hardware supports it, and nothing is
//  stored — the transcript exists only for the length of the session.
//

import AVFoundation
import Foundation
import Speech

@MainActor
final class SpeechRecognizer: ObservableObject {
    enum RecognizerError: LocalizedError {
        case nilRecognizer
        case notAuthorizedToRecognize
        case notPermittedToRecord
        case recognizerIsUnavailable

        var errorDescription: String? {
            switch self {
            case .nilRecognizer:
                return "Speech recognition is not available in this language."
            case .notAuthorizedToRecognize:
                return "Speech recognition permission is off. Turn it on in Settings."
            case .notPermittedToRecord:
                return "Microphone permission is off. Turn it on in Settings."
            case .recognizerIsUnavailable:
                return "Speech recognition is unavailable right now."
            }
        }
    }

    @Published private(set) var transcript = ""
    @Published private(set) var latestWord = ""
    @Published private(set) var isTranscribing = false
    @Published var errorMessage: String?

    private var audioEngine: AVAudioEngine?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private let recognizer = SFSpeechRecognizer()

    // MARK: - Permissions

    /// Requested when the user first presses record, rather than at launch.
    /// A microphone prompt on first open, before anything has been explained,
    /// reads as the app asking to listen to you.
    private func authorize() async throws {
        guard recognizer != nil else { throw RecognizerError.nilRecognizer }

        guard await SFSpeechRecognizer.hasAuthorizationToRecognize() else {
            throw RecognizerError.notAuthorizedToRecognize
        }
        guard await AVAudioApplication.requestRecordPermission() else {
            throw RecognizerError.notPermittedToRecord
        }
    }

    // MARK: - Transcribing

    func startTranscribing() async {
        errorMessage = nil

        do {
            try await authorize()

            guard let recognizer, recognizer.isAvailable else {
                throw RecognizerError.recognizerIsUnavailable
            }

            reset()

            let audioEngine = AVAudioEngine()
            let request = SFSpeechAudioBufferRecognitionRequest()
            request.shouldReportPartialResults = true
            request.requiresOnDeviceRecognition = recognizer.supportsOnDeviceRecognition

            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.record, mode: .measurement, options: .duckOthers)
            try session.setActive(true, options: .notifyOthersOnDeactivation)

            let inputNode = audioEngine.inputNode
            let format = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
                request.append(buffer)
            }

            audioEngine.prepare()
            try audioEngine.start()

            self.audioEngine = audioEngine
            self.request = request
            isTranscribing = true

            task = recognizer.recognitionTask(with: request) { [weak self] result, error in
                guard let self else { return }

                if let result {
                    Task { @MainActor in
                        self.update(with: result.bestTranscription.formattedString)
                    }
                }

                if result?.isFinal == true || error != nil {
                    Task { @MainActor in self.stopTranscribing() }
                }
            }
        } catch {
            reset()
            isTranscribing = false
            errorMessage = (error as? RecognizerError)?.errorDescription
                ?? error.localizedDescription
        }
    }

    func stopTranscribing() {
        reset()
        isTranscribing = false
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    func clear() {
        transcript = ""
        latestWord = ""
    }

    private func update(with text: String) {
        transcript = text
        latestWord = text.split(separator: " ").last.map(String.init) ?? ""
    }

    private func reset() {
        task?.cancel()
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        audioEngine = nil
        request = nil
        task = nil
    }
}

extension SFSpeechRecognizer {
    static func hasAuthorizationToRecognize() async -> Bool {
        await withCheckedContinuation { continuation in
            requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
}

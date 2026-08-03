//
//  SymbolSpeakView.swift
//  Walkie Talkie AAC
//
//  Speech in, symbol out. Whoever is talking — the wearer or their partner —
//  the last word said appears as a picture on the outward display.
//
//  Study participants valued this for people who cannot read or draw, and
//  also flagged the risk in it: showing a live transcript can create pressure
//  to "speak properly", which is the last thing an aphasia aid should do. So
//  the transcript is small and secondary, the picture is the screen, and
//  words with no picture simply show nothing rather than flagging a miss.
//

import SwiftUI

struct SymbolSpeakView: View {
    @StateObject private var recognizer = SpeechRecognizer()
    @State private var rotation: Double = 0

    @AppStorage(SettingsKeys.facesOutward) private var facesOutward = true

    private var assetName: String? {
        SymbolLibrary.assetName(for: recognizer.latestWord)
    }

    var body: some View {
        VStack(spacing: 0) {
            display
            transcript
            controls
        }
        .signageSurface(chevrons: false)
        .navigationTitle("Symbol Speak")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        rotation = (rotation + 180).truncatingRemainder(dividingBy: 360)
                    }
                } label: {
                    Label("Turn around", systemImage: "rotate.right.fill")
                }
            }
        }
        .onAppear { rotation = facesOutward ? 180 : 0 }
        .onDisappear { recognizer.stopTranscribing() }
        .alert(
            "Cannot listen",
            isPresented: Binding(
                get: { recognizer.errorMessage != nil },
                set: { if !$0 { recognizer.errorMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(recognizer.errorMessage ?? "")
        }
    }

    // MARK: - The outward display

    private var display: some View {
        GeometryReader { geometry in
        ZStack {
            SignagePalette.diversion.color

            VStack(spacing: 18) {
                if let assetName {
                    Image(assetName)
                        .resizable()
                        .scaledToFit()
                        // Proportional rather than a fixed 260pt, so the
                        // symbol grows with the screen it is shown on.
                        .frame(maxHeight: max(geometry.size.height * 0.42, 180))
                        .padding(.horizontal, 30)
                        .transition(.scale.combined(with: .opacity))
                } else if !recognizer.latestWord.isEmpty {
                    // No picture for this word. Show the word itself rather
                    // than an error — a blank screen mid-sentence reads as a
                    // fault, and the word is still useful.
                    Text(recognizer.latestWord)
                        .font(.appDisplay(AppFont.displaySize(
                            fillingWidth: geometry.size.width, factor: 0.31
                        )))
                        .minimumScaleFactor(0.2)
                        .lineLimit(1)
                        .foregroundStyle(SignagePalette.diversion.readableForeground)
                        .padding(.horizontal, 20)
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "mic.slash.fill")
                            .font(.system(size: 46, weight: .bold))
                        Text("Press listen, then talk")
                            .font(.appTitle3)
                    }
                    .foregroundStyle(SignagePalette.diversion.readableForeground.opacity(0.7))
                }

                if let word = displayWord {
                    Text(word.uppercased())
                        .font(.appTitle)
                        .kerning(1.5)
                        .foregroundStyle(SignagePalette.diversion.readableForeground)
                }
            }
            .rotationEffect(.degrees(rotation))
            .animation(.easeInOut(duration: 0.2), value: recognizer.latestWord)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(displayWord.map { "Showing \($0)" } ?? "Nothing showing yet")
    }

    private var displayWord: String? {
        guard assetName != nil else { return nil }
        return recognizer.latestWord
    }

    // MARK: - Transcript

    private var transcript: some View {
        Text(recognizer.transcript.isEmpty ? " " : recognizer.transcript)
            .font(.appFootnote)
            .foregroundStyle(SignagePalette.concrete.color)
            .lineLimit(2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .signageColumn()
            .accessibilityLabel("Heard so far: \(recognizer.transcript)")
    }

    // MARK: - Controls

    private var controls: some View {
        HStack(spacing: 10) {
            PressToTalkButton(
                title: recognizer.isTranscribing ? "Stop" : "Listen",
                systemIcon: recognizer.isTranscribing ? "stop.fill" : "mic.fill",
                tint: recognizer.isTranscribing ? SignagePalette.signalRed : SignagePalette.diversion
            ) {
                if recognizer.isTranscribing {
                    recognizer.stopTranscribing()
                } else {
                    Task { await recognizer.startTranscribing() }
                }
            }

            ControlButton(
                systemIcon: "xmark",
                label: "Clear",
                tint: SignagePalette.concrete
            ) {
                recognizer.clear()
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
        .signageColumn()
    }
}

#Preview {
    NavigationStack { SymbolSpeakView() }
}

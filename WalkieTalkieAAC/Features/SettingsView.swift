//
//  SettingsView.swift
//  Walkie Talkie AAC
//
//  Voice, speed, and how badges face.
//
//  A settings page was one of the study's explicit requests, and the two
//  sliders here are the two things participants disagreed about most: how
//  fast the voice talks, and how fast the words change. Neither has a right
//  answer, so neither is a constant.
//
//  Toggles first, then sliders. A toggle is a much easier control to operate
//  one-handed than a slider, so the easy wins come first.
//

import SwiftUI

struct SettingsView: View {
    @State private var settings = SettingsStore.shared
    private let tint = SignagePalette.concrete

    var body: some View {
        List {
            Section {
                Toggle(isOn: $settings.facesOutward) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Badges face outward")
                            .font(.appHeadline)
                        Text("Upside down to you, right way up to them")
                            .font(.appFootnote)
                            .foregroundStyle(SignagePalette.concrete.color)
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 14)
                .signageRowStyle()

            } header: {
                PlatformHeader(text: "Display", systemIcon: "rectangle.on.rectangle", tint: tint)
            } footer: {
                Text("Turn this off when you want to hold the phone normally instead of wearing it facing outward.")
                    .signageFooter()
            }

            Section {
                // The stored value is a duration, so invert the binding: right
                // is faster, matching the speaking-speed slider below.
                slider(
                    title: "Word-by-word speed",
                    value: Binding(
                        get: { WordPace.slowest + WordPace.fastest - settings.wordInterval },
                        set: { settings.wordInterval = WordPace.slowest + WordPace.fastest - $0 }
                    ),
                    range: WordPace.fastest...WordPace.slowest
                )
            } header: {
                PlatformHeader(text: "Word display", systemIcon: "textformat.size", tint: tint)
            } footer: {
                Text("How long each word stays on a one-word-at-a-time badge before the next one.")
                    .signageFooter()
            }

            Section {
                Toggle(isOn: $settings.prefersFemaleVoice) {
                    Text("Use a female voice")
                        .font(.appHeadline)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 14)
                .signageRowStyle()

                slider(
                    title: "Speaking speed",
                    value: $settings.speechRate,
                    range: Double(Speaker.slowestRate)...Double(Speaker.fastestRate)
                )

                Button {
                    Speaker.shared.speak("This is how I will sound.")
                } label: {
                    SignageRow(
                        title: "Test the voice",
                        systemIcon: "speaker.wave.3.fill",
                        tint: SignagePalette.motorway
                    )
                }
                .buttonStyle(.plain)
                .signageRowStyle()
            } header: {
                PlatformHeader(text: "Voice", systemIcon: "waveform", tint: tint)
            }
        }
        .listStyle(.plain)
        .signageContentWidth()
        .signageSurface()
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func slider(title: String, value: Binding<Double>, range: ClosedRange<Double>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.appHeadline)

            HStack(spacing: 12) {
                Image(systemName: "tortoise.fill")
                    .foregroundStyle(SignagePalette.concrete.color)
                    .accessibilityHidden(true)

                Slider(value: value, in: range)
                    .tint(SignagePalette.motorway.color)
                    .accessibilityLabel(title)

                Image(systemName: "hare.fill")
                    .foregroundStyle(SignagePalette.concrete.color)
                    .accessibilityHidden(true)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .signageRowStyle()
    }
}

#Preview {
    NavigationStack { SettingsView() }
}

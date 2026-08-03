//
//  DisplayView.swift
//  Walkie Talkie AAC
//
//  The badge itself: a full-screen sign, held out or worn facing outward.
//
//  Three decisions carry this screen.
//
//  It is rotated 180° by default. The phone hangs on a lanyard with the
//  screen facing away from the wearer, so the reader is opposite. "The right
//  way up" is upside down from where the wearer is standing.
//
//  It shows one word at a time, very large, rather than a sentence at a
//  readable size. A stranger glancing at a chest-height phone in a moving
//  carriage gets one word, so the word has to be enormous. "The bigger the
//  text the better" was the study's most direct piece of feedback.
//
//  Tapping anywhere speaks. Not automatically — speech is offered, never
//  imposed, because the display is meant to scaffold the wearer's own voice
//  rather than stand in for it.
//

import SwiftUI

struct DisplayView: View {
    let badge: Badge

    @State private var rotation: Double = 0
    @State private var isBlackedOut = false
    @State private var startedAt = Date()

    @Environment(\.dismiss) private var dismiss
    @AppStorage(SettingsKeys.facesOutward) private var facesOutward = true
    @AppStorage(SettingsKeys.showsSunflowerBadge) private var showsSunflower = false
    @AppStorage(SettingsKeys.wordInterval) private var wordInterval = WordPace.default

    private var words: [String] {
        let split = badge.displayText
            .split(whereSeparator: \.isWhitespace)
            .map(String.init)
        // Never return an empty array: the cycling index divides by count.
        return split.isEmpty ? [badge.label] : split
    }

    private var tint: SignColor { BadgeColor.sign(named: badge.colorName) }

    private var interval: Double {
        min(max(wordInterval, WordPace.fastest), WordPace.slowest)
    }

    var body: some View {
        ZStack {
            if isBlackedOut {
                // A real blackout, not a dimmed screen. Being able to make
                // the device disappear matters as much as being able to make
                // it shout — the wearer decides how visible their disability
                // is in any given room.
                Color.black.ignoresSafeArea()
            } else {
                tint.color.ignoresSafeArea()
                sign
            }

            controls
        }
        .contentShape(Rectangle())
        .onTapGesture { speak() }
        .statusBarHidden()
        .persistentSystemOverlays(.hidden)
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            rotation = facesOutward ? 180 : 0
            startedAt = Date()
            // Nobody wants their phone locking mid-sentence while it is being
            // read by someone else.
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
            Speaker.shared.stop()
        }
    }

    // MARK: - The sign face

    private var sign: some View {
        TimelineView(.periodic(from: startedAt, by: interval)) { context in
            let elapsed = context.date.timeIntervalSince(startedAt)
            let index = max(0, Int(elapsed / interval)) % words.count
            let word = words[index]

            VStack(spacing: 24) {
                Spacer(minLength: 0)

                // Swapped instantly, with no crossfade. Animating the change
                // renders both words stacked on top of each other for the
                // duration, which is exactly the moment someone is reading.
                Text(word)
                    .font(.appDisplay(220))
                    // Long words shrink rather than wrap. A hyphenated break
                    // across two lines is much harder to read at a glance.
                    .minimumScaleFactor(0.12)
                    .lineLimit(1)
                    .foregroundStyle(tint.readableForeground)
                    .padding(.horizontal, 20)

                Spacer(minLength: 0)

                progress(currentIndex: index)
            }
            .padding(.bottom, 96)
        }
        .rotationEffect(.degrees(rotation))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(badge.displayText)
        .accessibilityHint("Double tap to speak this badge")
    }

    /// A row of blocks showing where in the sentence the display has got to,
    /// so a reader can tell whether to wait for more.
    private func progress(currentIndex: Int) -> some View {
        HStack(spacing: 5) {
            ForEach(words.indices, id: \.self) { index in
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(tint.readableForeground)
                    .opacity(index == currentIndex ? 1 : 0.3)
                    .frame(height: 5)
            }
        }
        .padding(.horizontal, 40)
        .accessibilityHidden(true)
    }

    // MARK: - Controls

    private var controls: some View {
        // Every control derives its colours from whatever is behind it, so
        // they stay legible on all eight badge colours and on the blackout.
        let surface = isBlackedOut ? SignagePalette.signInk : tint

        return VStack {
            Spacer()

            HStack(spacing: 10) {
                ControlButton(
                    systemIcon: "chevron.left",
                    label: "Close",
                    surface: surface
                ) {
                    dismiss()
                }

                ControlButton(
                    systemIcon: "speaker.wave.3.fill",
                    label: "Speak this badge",
                    surface: surface
                ) {
                    speak()
                }

                ControlButton(
                    systemIcon: "rotate.right.fill",
                    label: "Turn the badge around",
                    surface: surface
                ) {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        rotation = (rotation + 180).truncatingRemainder(dividingBy: 360)
                    }
                }

                ControlButton(
                    systemIcon: isBlackedOut ? "eye.fill" : "eye.slash.fill",
                    label: isBlackedOut ? "Show the badge" : "Hide the badge",
                    surface: surface
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) { isBlackedOut.toggle() }
                }

                if showsSunflower && !isBlackedOut {
                    ControlButton(
                        systemIcon: BadgeLibrary.sunflowerIcon,
                        label: "Hidden disability",
                        surface: surface
                    ) {
                        Speaker.shared.speak("I have a hidden disability.")
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
    }

    private func speak() {
        Speaker.shared.speak(badge.displayText, languageCode: badge.languageCode)
    }
}

#Preview {
    NavigationStack {
        DisplayView(badge: BadgeLibrary.defaults[3])
    }
}

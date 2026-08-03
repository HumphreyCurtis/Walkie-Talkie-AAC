//
//  AttentionView.swift
//  Walkie Talkie AAC
//
//  For when the wearer needs to be noticed and nobody is looking.
//
//  The colour escalates green → amber → red over about fifteen seconds. That
//  came straight out of a co-design session: participants wanted the badge to
//  go "green, orange and red", to depict growing impatience — a queue you
//  cannot verbally jump, expressed as a traffic light.
//
//  It escalates on its own but it never starts on its own. And it can be
//  killed instantly with the hide button, because the whole point is that the
//  wearer controls how loud they are being.
//

import SwiftUI

struct AttentionView: View {
    @State private var message = "EXCUSE ME PLEASE"
    @State private var isRunning = false
    @State private var startedAt = Date()
    @State private var rotation: Double = 0

    @AppStorage(SettingsKeys.facesOutward) private var facesOutward = true
    @AppStorage(SettingsKeys.wordInterval) private var wordInterval = WordPace.default

    /// How long the escalation takes to reach full red.
    private let escalation: Double = 15

    private var words: [String] {
        let split = message.split(whereSeparator: \.isWhitespace).map(String.init)
        return split.isEmpty ? ["HELLO"] : split
    }

    private var interval: Double {
        min(max(wordInterval, WordPace.fastest), WordPace.slowest)
    }

    var body: some View {
        Group {
            if isRunning {
                running
            } else {
                setup
            }
        }
        .navigationTitle("Attention")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(isRunning ? .hidden : .visible, for: .navigationBar)
        .statusBarHidden(isRunning)
        .onChange(of: isRunning) { _, nowRunning in
            UIApplication.shared.isIdleTimerDisabled = nowRunning
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }

    // MARK: - Before it starts

    private var setup: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 10) {
                PlatformHeader(text: "Message", tint: SignagePalette.signalRed)

                TextField("Excuse me please", text: $message, axis: .vertical)
                    .font(.appTitle3)
                    .lineLimit(1...3)
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(SignagePalette.concrete.color.opacity(0.12))
                    )
            }

            Text("The display starts green and turns red over about fifteen seconds. Tap it to speak, or hide it at any time.")
                .font(.appFootnote)
                .foregroundStyle(SignagePalette.concrete.color)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            PressToTalkButton(
                title: "Start",
                systemIcon: "exclamationmark.triangle.fill",
                tint: SignagePalette.signalRed
            ) {
                rotation = facesOutward ? 180 : 0
                startedAt = Date()
                withAnimation(.easeInOut(duration: 0.2)) { isRunning = true }
            }
        }
        .padding(20)
        .signageColumn()
        .signageSurface()
    }

    // MARK: - While it runs

    private var running: some View {
        TimelineView(.periodic(from: startedAt, by: min(interval, 0.25))) { context in
            let elapsed = context.date.timeIntervalSince(startedAt)
            let urgency = min(elapsed / escalation, 1)
            let background = escalationColor(urgency: urgency)
            let index = max(0, Int(elapsed / interval)) % words.count

            ZStack {
                background.color.ignoresSafeArea()

                Text(words[index])
                    .font(.appDisplay(240))
                    .minimumScaleFactor(0.1)
                    .lineLimit(1)
                    .foregroundStyle(background.readableForeground)
                    .padding(.horizontal, 16)
                    .rotationEffect(.degrees(rotation))
                    // Once it is fully red it pulses, which reads as urgent
                    // in peripheral vision in a way a static colour does not.
                    // No animation on the word change itself — a crossfade
                    // stacks two words on top of each other while they are
                    // being read.
                    .scaleEffect(urgency >= 1 ? pulse(elapsed: elapsed) : 1)

                controls(surface: background)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                Speaker.shared.speak(message)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(message)
            .accessibilityHint("Double tap to speak")
        }
    }

    /// The controls take their colours from the live escalation colour, so
    /// they stay readable all the way from green through amber to red.
    private func controls(surface: SignColor) -> some View {
        VStack {
            Spacer()
            HStack(spacing: 10) {
                ControlButton(
                    systemIcon: "stop.fill",
                    label: "Stop",
                    surface: surface
                ) {
                    Speaker.shared.stop()
                    withAnimation(.easeInOut(duration: 0.2)) { isRunning = false }
                }

                ControlButton(
                    systemIcon: "speaker.wave.3.fill",
                    label: "Speak",
                    surface: surface
                ) {
                    Speaker.shared.speak(message)
                }

                ControlButton(
                    systemIcon: "rotate.right.fill",
                    label: "Turn around",
                    surface: surface
                ) {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        rotation = (rotation + 180).truncatingRemainder(dividingBy: 360)
                    }
                }

                ControlButton(
                    systemIcon: "arrow.counterclockwise",
                    label: "Start again",
                    surface: surface
                ) {
                    startedAt = Date()
                }
            }
            .padding(.bottom, 12)
        }
    }

    // MARK: - Escalation

    /// Green through amber to red. Interpolated in RGB, which is fine here
    /// because the three stops are already close to the hue path between
    /// them and the result stays saturated.
    private func escalationColor(urgency: Double) -> SignColor {
        let stops = [SignagePalette.routeGreen, SignagePalette.amber, SignagePalette.signalRed]
        let scaled = urgency * Double(stops.count - 1)
        let lower = min(Int(scaled), stops.count - 2)
        let fraction = scaled - Double(lower)

        return blend(stops[lower], stops[lower + 1], fraction: fraction)
    }

    private func blend(_ from: SignColor, _ to: SignColor, fraction: Double) -> SignColor {
        func channel(_ hex: UInt32, _ shift: UInt32) -> Double {
            Double((hex >> shift) & 0xFF)
        }
        var result: UInt32 = 0
        for shift in stride(from: UInt32(16), through: 0, by: -8) {
            let mixed = channel(from.hex, shift) * (1 - fraction) + channel(to.hex, shift) * fraction
            result |= UInt32(mixed.rounded()) << shift
        }
        return SignColor(hex: result)
    }

    private func pulse(elapsed: Double) -> Double {
        1 + 0.04 * sin(elapsed * 4)
    }
}

#Preview {
    NavigationStack { AttentionView() }
}

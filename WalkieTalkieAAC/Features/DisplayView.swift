import SwiftUI
import UIKit

struct DisplayView: View {
    let badge: Badge

    @State private var current: Badge
    @State private var rotation: Double = 0
    @State private var isBlackedOut = false
    @State private var backgroundImage: UIImage?
    @State private var sequenceStartedAt = Date()

    @Environment(\.dismiss) private var dismiss
    @AppStorage(SettingsKeys.facesOutward) private var facesOutward = true
    @AppStorage(SettingsKeys.wordInterval) private var wordInterval = WordPace.default

    private let store = BadgeStore.shared

    init(badge: Badge) {
        self.badge = badge
        _current = State(initialValue: badge)
    }

    private var tint: SignColor { BadgeColor.sign(named: current.colorName) }
    private var foreground: Color {
        backgroundImage != nil ? .white : tint.readableForeground
    }
    private var words: [String] {
        let values = current.displayText.split(whereSeparator: \.isWhitespace).map(String.init)
        return values.isEmpty ? ["—"] : values
    }
    private var interval: Double {
        min(max(wordInterval, WordPace.fastest), WordPace.slowest)
    }

    var body: some View {
        ZStack {
            background

            VStack(spacing: 0) {
                if isBlackedOut {
                    Spacer(minLength: 0)
                } else {
                    sign
                }

                controls
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { speak() }
        .statusBarHidden()
        .persistentSystemOverlays(.hidden)
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            rotation = facesOutward ? 180 : 0
            backgroundImage = store.image(for: current)
            sequenceStartedAt = Date()
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
            Speaker.shared.stop()
        }
    }

    @ViewBuilder
    private var background: some View {
        if isBlackedOut {
            Color.black.ignoresSafeArea()
        } else if let backgroundImage {
            Image(uiImage: backgroundImage)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .overlay {
                    LinearGradient(
                        colors: [.black.opacity(0.5), .black.opacity(0.2)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                }
        } else {
            tint.color.ignoresSafeArea()
        }
    }

    private var sign: some View {
        GeometryReader { geometry in
            // This reader receives only the space above the control bar,
            // because the two are siblings in a VStack rather than layers in
            // a ZStack. They therefore cannot overlap in any orientation.
            let verticalInset: CGFloat = 10
            let contentSize = CGSize(
                width: max(80, geometry.size.width - 40),
                height: max(44, geometry.size.height - verticalInset * 2)
            )

            Group {
                if current.displayMode == .wordByWord {
                    TimelineView(.periodic(from: sequenceStartedAt, by: min(interval, 0.25))) { context in
                        wordLayout(
                            word: word(at: context.date),
                            size: contentSize
                        )
                    }
                } else {
                    wholeMessageLayout(size: contentSize)
                }
            }
            .foregroundStyle(foreground)
            .shadow(color: .black.opacity(backgroundImage == nil ? 0 : 0.55), radius: 8)
            .frame(width: contentSize.width, height: contentSize.height)
            .clipped()
            .position(
                x: geometry.size.width / 2,
                y: geometry.size.height - verticalInset - contentSize.height / 2
            )
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(current.displayText)
        .accessibilityHint("Double tap to speak this badge")
    }

    private func wholeMessageLayout(size: CGSize) -> some View {
        let spacing = min(12, max(6, size.height * 0.025))
        let symbolSize = min(size.width * 0.18, max(38, min(64, size.height * 0.16)))
        let textHeight = max(24, size.height - symbolSize - spacing)
        let textArea = CGSize(width: size.width - 12, height: textHeight)
        let fontSize = fittedSize(
            for: current.displayText,
            in: textArea,
            singleLine: false,
            scale: current.textScale
        )
        let renderedTextHeight = measuredTextHeight(
            for: current.displayText,
            width: textArea.width,
            fontSize: fontSize,
            maximum: textHeight
        )

        return VStack(spacing: spacing) {
            displayText(current.displayText, size: fontSize, singleLine: false)
                .frame(height: renderedTextHeight)
            badgeSymbol(size: symbolSize)
                .frame(height: symbolSize)
                .frame(maxWidth: .infinity)
        }
        .frame(width: size.width, height: size.height, alignment: .center)
    }

    private func wordLayout(word: String, size: CGSize) -> some View {
        let spacing = min(12, max(6, size.height * 0.025))
        let symbolSize = min(size.width * 0.18, max(38, min(64, size.height * 0.16)))
        let textHeight = max(24, size.height - symbolSize - spacing)
        let textArea = CGSize(width: size.width - 12, height: textHeight)
        // Size every word from the most demanding word so the display does
        // not jump larger and smaller as the sentence advances.
        let fontSize = words.map {
            fittedSize(for: $0, in: textArea, singleLine: true, scale: current.textScale)
        }.min() ?? 48
        let renderedTextHeight = measuredTextHeight(
            for: word,
            width: textArea.width,
            fontSize: fontSize,
            maximum: textHeight
        )

        return VStack(spacing: spacing) {
            displayText(word, size: fontSize, singleLine: true)
                .frame(height: renderedTextHeight)
                .id(word)
            badgeSymbol(size: symbolSize)
                .frame(height: symbolSize)
                .frame(maxWidth: .infinity)
        }
        .frame(width: size.width, height: size.height)
    }

    @ViewBuilder
    private func badgeSymbol(size: CGFloat) -> some View {
        if let emoji = current.emoji, !emoji.isEmpty {
            Text(emoji)
                .font(.system(size: size * 0.88))
                .rotationEffect(.degrees(rotation))
                .frame(width: size, height: size)
        } else {
            Image(systemName: current.systemIcon)
                .font(.system(size: size * 0.74, weight: .bold))
                .rotationEffect(.degrees(rotation))
                .frame(width: size, height: size)
        }
    }

    private func displayText(_ text: String, size: CGFloat, singleLine: Bool) -> some View {
        Text(text)
            .font(.appDisplay(size))
            .lineLimit(singleLine ? 1 : nil)
            .minimumScaleFactor(0.9)
            .multilineTextAlignment(.center)
            .allowsTightening(true)
            .layoutPriority(1)
            .rotationEffect(.degrees(rotation))
            .frame(maxWidth: .infinity, alignment: .center)
    }

    /// Binary-searches the largest DIN size whose measured bounds fit the
    /// available rectangle. UIFont falls back by glyph, so non-Latin scripts
    /// are measured with the same fallback iOS uses when SwiftUI draws them.
    private func fittedSize(
        for text: String,
        in available: CGSize,
        singleLine: Bool,
        scale: Double
    ) -> CGFloat {
        guard available.width > 0, available.height > 0 else { return 24 }
        var lower: CGFloat = 12
        var upper: CGFloat = max(available.width, available.height) * 1.2

        for _ in 0..<12 {
            let candidate = (lower + upper) / 2
            let font = UIFont(name: AppFont.signage, size: candidate)
                ?? UIFont.boldSystemFont(ofSize: candidate)
            let constraint = CGSize(
                width: available.width,
                height: singleLine ? .greatestFiniteMagnitude : available.height
            )
            let bounds = (text as NSString).boundingRect(
                with: constraint,
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: [.font: font],
                context: nil
            )
            let widestWord = text.split(whereSeparator: \.isWhitespace)
                .map { token in
                    (String(token) as NSString).size(withAttributes: [.font: font]).width
                }
                .max() ?? 0
            let fitsHeight = bounds.height <= available.height
            let fitsWidth = bounds.width <= available.width + 1
                && widestWord <= available.width + 1
            if fitsHeight && fitsWidth {
                lower = candidate
            } else {
                upper = candidate
            }
        }
        let scaled = lower * 0.90 * min(max(scale, 0.6), 1)
        let cap = singleLine
            ? min(available.width * 0.52, available.height * 0.78)
            : min(available.width * 0.20, available.height * 0.24)
        return max(12, min(scaled, cap))
    }

    private func measuredTextHeight(
        for text: String,
        width: CGFloat,
        fontSize: CGFloat,
        maximum: CGFloat
    ) -> CGFloat {
        let font = UIFont(name: AppFont.signage, size: fontSize)
            ?? UIFont.boldSystemFont(ofSize: fontSize)
        let bounds = (text as NSString).boundingRect(
            with: CGSize(width: width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font],
            context: nil
        )
        // A small allowance covers SwiftUI/UIKit line-metric differences
        // without recreating the oversized invisible text frame.
        return min(maximum, max(font.lineHeight, ceil(bounds.height) + 6))
    }

    private func word(at date: Date) -> String {
        // The extra sequence slot repeats the final word once, producing one
        // additional interval of pause before the sentence starts again.
        let elapsed = max(0, date.timeIntervalSince(sequenceStartedAt))
        let index = Int(elapsed / interval) % (words.count + 1)
        return words[min(index, words.count - 1)]
    }

    private var controls: some View {
        let surface = isBlackedOut
            ? SignagePalette.signInk
            : (backgroundImage != nil ? SignagePalette.signInk : tint)

        return HStack(spacing: 10) {
            ControlButton(systemIcon: "chevron.left", label: "Back", surface: surface) {
                dismiss()
            }
            ControlButton(
                systemIcon: "speaker.wave.3.fill",
                label: "Speak this badge",
                surface: surface
            ) { speak() }
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
        }
        .padding(.horizontal, 12)
        .padding(.top, 14)
        .padding(.bottom, 20)
    }

    private func speak() {
        Speaker.shared.speak(current.displayText, languageCode: current.languageCode)
    }
}

#Preview {
    NavigationStack { DisplayView(badge: BadgeLibrary.defaults[0]) }
}

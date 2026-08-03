//
//  DisplayView.swift
//  Walkie Talkie AAC
//
//  The badge itself: a full-screen sign, worn on a lanyard or an arm strap
//  and read by the person opposite.
//
//  The whole message is on screen at once, wrapped over as many lines as it
//  needs, sized to fill the display. Not one word at a time — that is the
//  Attention screen's job, for when you need to be noticed. A badge is
//  something someone reads at their own pace while you stand there, so it has
//  to still be there while they read it.
//
//  It is rotated 180° by default. The phone hangs with the screen facing away
//  from the wearer, so "the right way up" is upside down from where they are
//  standing.
//
//  The background is a colour or a photo. The photo is not decoration: a
//  co-designer held his phone against a striped shirt so the badge vanished
//  into what he was wearing. Being able to make the device disappear matters
//  as much as being able to make it shout, and both are the wearer's call.
//
//  Tapping anywhere speaks it. Never automatically — the display is meant to
//  scaffold the wearer's own voice, not replace it with a synthetic one.
//

import PhotosUI
import SwiftUI

struct DisplayView: View {
    let badge: Badge

    @State private var current: Badge
    @State private var rotation: Double = 0
    @State private var isBlackedOut = false
    @State private var backgroundImage: UIImage?
    @State private var showingCamera = false
    @State private var showingColours = false
    @State private var pickerItem: PhotosPickerItem?

    @Environment(\.dismiss) private var dismiss
    @AppStorage(SettingsKeys.facesOutward) private var facesOutward = true
    @AppStorage(SettingsKeys.showsSunflowerBadge) private var showsSunflower = false

    private let store = BadgeStore.shared

    init(badge: Badge) {
        self.badge = badge
        _current = State(initialValue: badge)
    }

    private var tint: SignColor { BadgeColor.sign(named: current.colorName) }

    /// What the text sits on, which decides whether it is white or ink.
    /// Over a photo it is always white with a scrim, because the photo could
    /// be anything.
    private var foreground: Color {
        backgroundImage != nil ? .white : tint.readableForeground
    }

    var body: some View {
        ZStack {
            background
            if !isBlackedOut { sign }
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
            backgroundImage = store.image(for: current)
            // Nobody wants their phone locking mid-sentence while it is being
            // read by somebody else.
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
            Speaker.shared.stop()
        }
        .fullScreenCover(isPresented: $showingCamera) {
            CameraPicker(image: Binding(
                get: { nil },
                set: { image in if let image { apply(photo: image) } }
            ))
            .ignoresSafeArea()
        }
        .onChange(of: pickerItem) { _, item in
            guard let item else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    apply(photo: image)
                }
            }
        }
    }

    // MARK: - Background

    @ViewBuilder
    private var background: some View {
        if isBlackedOut {
            // A real blackout, not a dimmed screen.
            Color.black.ignoresSafeArea()
        } else if let backgroundImage {
            Image(uiImage: backgroundImage)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .overlay {
                    // Just enough shading to keep white text legible over an
                    // unknown photo, without undoing the camouflage.
                    LinearGradient(
                        colors: [.black.opacity(0.45), .black.opacity(0.15)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                }
        } else {
            tint.color.ignoresSafeArea()
        }
    }

    // MARK: - The sign face

    private var sign: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 18) {
                Text(current.displayText)
                    .font(.appDisplay(textSize(in: geometry.size)))
                    // As many lines as it takes. A message that has been
                    // truncated is a message that failed.
                    .lineLimit(nil)
                    .minimumScaleFactor(0.25)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                if let emoji = current.emoji, !emoji.isEmpty {
                    Text(emoji)
                        .font(.system(size: textSize(in: geometry.size) * 0.9))
                }
            }
            .foregroundStyle(foreground)
            .shadow(color: .black.opacity(backgroundImage == nil ? 0 : 0.5), radius: 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 28)
            .frame(width: geometry.size.width, height: geometry.size.height * 0.82)
        }
        .rotationEffect(.degrees(rotation))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(current.displayText)
        .accessibilityHint("Double tap to speak this badge")
    }

    /// Sized to the screen and to how much there is to say, so a short message
    /// fills the sign and a long one still fits.
    ///
    /// Proportional to width rather than a fixed point size: a size that fills
    /// an iPhone leaves a message stranded in the middle of an iPad, and this
    /// is meant to be read from across a carriage.
    private func textSize(in size: CGSize) -> CGFloat {
        let width = max(size.width, 320)
        let characters = max(current.displayText.count, 1)

        let base: CGFloat
        switch characters {
        case ..<12: base = 0.30
        case ..<25: base = 0.20
        case ..<45: base = 0.145
        case ..<80: base = 0.11
        default: base = 0.085
        }
        return width * base
    }

    // MARK: - Controls

    private var controls: some View {
        // Every control takes its colours from what is behind it, so they
        // stay legible on all eight badge colours, on a photo, and on the
        // blackout.
        let surface = isBlackedOut
            ? SignagePalette.signInk
            : (backgroundImage != nil ? SignagePalette.signInk : tint)

        return VStack {
            Spacer()

            HStack(spacing: 8) {
                ControlButton(systemIcon: "chevron.left", label: "Close", surface: surface) {
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
                    systemIcon: "paintpalette.fill",
                    label: "Change the colour",
                    surface: surface
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) { showingColours.toggle() }
                }

                photoControl(surface: surface)

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
            .padding(.horizontal, 12)

            if showingColours {
                colourStrip
            }
        }
        .padding(.bottom, 20)
    }

    /// Camera when there is no photo, remove when there is. Choosing from the
    /// library lives in the colour strip, so this stays a single tap for the
    /// case the study actually showed — holding the phone up to your own
    /// shirt and shooting it.
    @ViewBuilder
    private func photoControl(surface: SignColor) -> some View {
        if backgroundImage == nil {
            ControlButton(
                systemIcon: "camera.fill",
                label: "Take a background photo",
                surface: surface
            ) {
                showingCamera = true
            }
        } else {
            ControlButton(
                systemIcon: "photo.badge.minus.fill",
                label: "Remove the background photo",
                surface: surface
            ) {
                apply(photo: nil)
            }
        }
    }

    private var colourStrip: some View {
        HStack(spacing: 8) {
            ForEach(BadgeColor.names, id: \.self) { name in
                let sign = BadgeColor.sign(named: name)
                Button {
                    current.colorName = name
                    store.update(current)
                } label: {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(sign.color)
                        .frame(height: 44)
                        // Outlined, or the swatch matching the badge's own
                        // colour disappears into the background behind it and
                        // the checkmark floats in mid-air.
                        .overlay {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .strokeBorder(foreground.opacity(0.9), lineWidth: 2)
                        }
                        .overlay {
                            if current.colorName == name && backgroundImage == nil {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(sign.readableForeground)
                            }
                        }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(BadgeColor.routeName(for: name))
            }

            PhotosPicker(selection: $pickerItem, matching: .images) {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .frame(width: 52, height: 44)
                    .overlay {
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 16, weight: .bold))
                    }
            }
            .accessibilityLabel("Choose a background photo")
        }
        .padding(.horizontal, 12)
        .padding(.top, 10)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    // MARK: - Actions

    private func apply(photo: UIImage?) {
        current = store.setImage(photo, for: current)
        backgroundImage = photo
    }

    private func speak() {
        Speaker.shared.speak(current.displayText, languageCode: current.languageCode)
    }
}

#Preview {
    NavigationStack {
        DisplayView(badge: BadgeLibrary.defaults[3])
    }
}

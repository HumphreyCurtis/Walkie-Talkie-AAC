//
//  BadgeEditorView.swift
//  Walkie Talkie AAC
//
//  Create or change one badge, with a live preview of how it will look to
//  the person reading it.
//
//  The preview is not decoration. The wearer never sees the badge the way
//  their reader does — it is pointing away from them — so without a preview
//  they are choosing a colour and a size blind.
//

import SwiftUI

struct BadgeEditorView: View {
    /// `nil` creates a new badge.
    let badge: Badge?

    @State private var label = ""
    @State private var displayText = ""
    @State private var systemIcon = "text.bubble.fill"
    @State private var emoji = ""
    @State private var colorName = BadgeColor.defaultName
    @State private var languageCode = ""
    @State private var displayMode: BadgeDisplayMode = .wholeMessage
    @State private var textScale = 1.0

    @Environment(\.dismiss) private var dismiss
    private let store = BadgeStore.shared

    private var isValid: Bool {
        !label.trimmingCharacters(in: .whitespaces).isEmpty
            && !displayText.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var tint: SignColor { BadgeColor.sign(named: colorName) }

    var body: some View {
        Form {
            Section {
                preview
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }

            Section {
                TextField("Help", text: $label)
                    .font(.appBody)
            } header: {
                PlatformHeader(text: "Short name", tint: tint)
            } footer: {
                Text("One or two words. This is what you look for in the list.")
                    .font(.appFootnote)
            }

            Section {
                TextField("Please can you help me?", text: $displayText, axis: .vertical)
                    .font(.appBody)
                    .lineLimit(2...6)
            } header: {
                PlatformHeader(text: "Message", tint: tint)
            } footer: {
                Text("Shown in large type, and spoken if you tap the badge.")
                    .font(.appFootnote)
            }

            Section {
                Picker("Display style", selection: $displayMode) {
                    ForEach(BadgeDisplayMode.allCases, id: \.self) { mode in
                        Text(mode.title).tag(mode)
                    }
                }
                .pickerStyle(.segmented)

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Letter size")
                            .font(.appHeadline)
                        Spacer()
                        Text(textScale >= 0.99 ? "Largest" : "\(Int(textScale * 100))%")
                            .font(.appFootnote)
                            .foregroundStyle(SignagePalette.concrete.color)
                    }

                    HStack(spacing: 12) {
                        Image(systemName: "textformat.size.smaller")
                            .foregroundStyle(SignagePalette.concrete.color)
                        Slider(value: $textScale, in: 0.6...1, step: 0.05)
                            .tint(tint.color)
                            .accessibilityLabel("Letter size")
                        Image(systemName: "textformat.size.larger")
                            .foregroundStyle(tint.color)
                    }
                }
                .padding(.vertical, 4)
            } header: {
                PlatformHeader(text: "Display", tint: tint)
            } footer: {
                Text(displayMode == .wordByWord
                     ? "Each word fills the screen, then the message repeats."
                     : "The whole message stays visible for the reader.")
                    .font(.appFootnote)
            }

            Section {
                colorPicker
                iconPicker
                TextField("Emoji (optional)", text: $emoji)
                    .font(.appBody)
            } header: {
                PlatformHeader(text: "Look", tint: tint)
            } footer: {
                Text("An emoji replaces the symbol when you add one.")
                    .font(.appFootnote)
            }

            Section {
                NavigationLink {
                    LanguagePickerView(selection: $languageCode)
                } label: {
                    HStack {
                        Text("Spoken language")
                            .font(.appHeadline)
                        Spacer()
                        Text(LanguagePickerView.name(for: languageCode))
                            .font(.appFootnote)
                            .foregroundStyle(SignagePalette.concrete.color)
                            .lineLimit(1)
                    }
                }
            } header: {
                PlatformHeader(text: "Language", tint: tint)
            } footer: {
                Text("This chooses the voice used when you speak the badge. It does not translate your message.")
                    .font(.appFootnote)
            }
        }
        .signageSurface(chevrons: false)
        .navigationTitle(badge == nil ? "New Badge" : "Edit Badge")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { save() }
                    .disabled(!isValid)
                    .fontWeight(.semibold)
            }
        }
        .onAppear(perform: load)
    }

    // MARK: - Preview

    private var preview: some View {
        VStack(spacing: 0) {
            ZStack {
                tint.color

                HStack(spacing: 16) {
                    if emoji.trimmingCharacters(in: .whitespaces).isEmpty {
                        Image(systemName: systemIcon)
                            .font(.system(size: 42, weight: .bold))
                    } else {
                        Text(emoji)
                            .font(.system(size: 42))
                    }

                    Text(previewText)
                        .font(.appDisplay(54 * textScale))
                        .minimumScaleFactor(0.2)
                        .lineLimit(displayMode == .wordByWord ? 1 : 3)
                        .multilineTextAlignment(.leading)
                }
                .foregroundStyle(tint.readableForeground)
                .padding(.horizontal, 18)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: 160)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            Text(displayMode == .wordByWord ? "How each word will look" : "How the badge will look")
                .font(.appCaption)
                .foregroundStyle(SignagePalette.concrete.color)
                .padding(.top, 8)
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Preview, \(BadgeColor.routeName(for: colorName))")
    }

    private var previewText: String {
        let trimmed = displayText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "—" }
        if displayMode == .wordByWord {
            return trimmed.split(whereSeparator: \.isWhitespace).first.map(String.init) ?? "—"
        }
        return trimmed
    }

    // MARK: - Pickers

    private var colorPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Colour")
                .font(.appSubheadline)
                .foregroundStyle(SignagePalette.concrete.color)

            HStack(spacing: 10) {
                ForEach(BadgeColor.names, id: \.self) { name in
                    let sign = BadgeColor.sign(named: name)
                    Button {
                        colorName = name
                    } label: {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(sign.color)
                            .frame(height: 40)
                            .overlay {
                                if colorName == name {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundStyle(sign.readableForeground)
                                }
                            }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(BadgeColor.routeName(for: name))
                    .accessibilityAddTraits(colorName == name ? [.isSelected] : [])
                }
            }
        }
        .padding(.vertical, 4)
    }

    private var iconPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Symbol")
                .font(.appSubheadline)
                .foregroundStyle(SignagePalette.concrete.color)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(
                    rows: [
                        GridItem(.fixed(46), spacing: 10),
                        GridItem(.fixed(46), spacing: 10),
                    ],
                    spacing: 10
                ) {
                    ForEach(BadgeTransfer.suggestedIcons, id: \.self) { name in
                        Button {
                            systemIcon = name
                        } label: {
                            Image(systemName: name)
                                .font(.system(size: 19, weight: .semibold))
                                .frame(width: 46, height: 46)
                                .foregroundStyle(
                                    systemIcon == name ? tint.readableForeground : Color.primary
                                )
                                .background(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(systemIcon == name
                                              ? tint.color
                                              : SignagePalette.concrete.color.opacity(0.15))
                                )
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(name)
                        .accessibilityAddTraits(systemIcon == name ? [.isSelected] : [])
                    }
                }
                .padding(.horizontal, 1)
            }
            .frame(height: 102)
        }
        .padding(.vertical, 4)
    }

    // MARK: - Persistence

    private func load() {
        guard let badge else { return }
        label = badge.label
        displayText = badge.displayText
        systemIcon = badge.systemIcon
        emoji = badge.emoji ?? ""
        colorName = badge.colorName ?? BadgeColor.defaultName
        languageCode = badge.languageCode ?? ""
        displayMode = badge.displayMode
        textScale = badge.textScale
    }

    private func save() {
        let trimmedEmoji = emoji.trimmingCharacters(in: .whitespaces)
        let trimmedLanguage = languageCode.trimmingCharacters(in: .whitespaces)

        let updated = Badge(
            id: badge?.id ?? UUID(),
            label: label.trimmingCharacters(in: .whitespaces),
            displayText: displayText.trimmingCharacters(in: .whitespaces),
            systemIcon: systemIcon,
            emoji: trimmedEmoji.isEmpty ? nil : trimmedEmoji,
            colorName: colorName,
            languageCode: trimmedLanguage.isEmpty ? nil : trimmedLanguage,
            displayMode: displayMode,
            textScale: textScale,
            backgroundImageName: badge?.backgroundImageName
        )

        if badge == nil {
            store.add(updated)
        } else {
            store.update(updated)
        }
        dismiss()
    }
}

#Preview {
    NavigationStack { BadgeEditorView(badge: BadgeLibrary.defaults[0]) }
}

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
                TextField("e.g. fr-FR", text: $languageCode)
                    .font(.appBody)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            } header: {
                PlatformHeader(text: "Language", tint: tint)
            } footer: {
                Text("Leave empty to use your phone's language. Set it to speak this badge in another one.")
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
                Text(displayText.split(separator: " ").first.map(String.init) ?? "—")
                    .font(.appDisplay(72))
                    .minimumScaleFactor(0.3)
                    .lineLimit(1)
                    .foregroundStyle(tint.readableForeground)
                    .padding(.horizontal, 16)
            }
            .frame(height: 140)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            Text("How the first word will look")
                .font(.appCaption)
                .foregroundStyle(SignagePalette.concrete.color)
                .padding(.top, 8)
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Preview, \(BadgeColor.routeName(for: colorName))")
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
                HStack(spacing: 10) {
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
            languageCode: trimmedLanguage.isEmpty ? nil : trimmedLanguage
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

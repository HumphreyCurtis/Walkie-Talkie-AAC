//
//  ImportBadgesView.swift
//  Walkie Talkie AAC
//
//  Write badges with whatever assistant the user already has, via the
//  clipboard. Three numbered steps, because this is the most procedural
//  screen in the app and the order matters.
//
//  The app makes no network calls and holds no API key. It writes a prompt
//  and reads a reply; the user chooses which assistant sees it, and can read
//  the prompt before sending it.
//

import SwiftUI

struct ImportBadgesView: View {
    @State private var pasted = ""
    @State private var changes: [BadgeTransfer.Change] = []
    @State private var merged: [Badge] = []
    @State private var errorMessage: String?
    @State private var didCopyPrompt = false

    @Environment(\.dismiss) private var dismiss
    private let store = BadgeStore.shared

    var body: some View {
        Form {
            promptSection
            pasteSection

            if !changes.isEmpty {
                reviewSection
            }
        }
        .signageSurface(chevrons: false)
        .navigationTitle("Write with AI")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") { dismiss() }
            }
            if !merged.isEmpty {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { apply() }
                        .fontWeight(.semibold)
                }
            }
        }
        .alert(
            "Could not read that",
            isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "")
        }
    }

    // MARK: - Step one

    private var promptSection: some View {
        Section {
            Button {
                UIPasteboard.general.string = BadgeTransfer.prompt(for: store.badges)
                didCopyPrompt = true
            } label: {
                SignageRow(
                    title: didCopyPrompt ? "Copied" : "Copy the prompt",
                    subtitle: didCopyPrompt
                        ? "Now paste it into ChatGPT, Claude or Gemini"
                        : "Includes your badges, so it can edit them too",
                    systemIcon: didCopyPrompt ? "checkmark.circle.fill" : "doc.on.doc.fill",
                    tint: didCopyPrompt ? SignagePalette.routeGreen : SignagePalette.diversion
                )
            }
            .buttonStyle(.plain)
            .signageRowStyle()
        } header: {
            PlatformHeader(text: "Step 1", systemIcon: "1.circle", tint: SignagePalette.diversion)
        } footer: {
            Text("Ask for what you need in your own words — \"badges for a hospital appointment\", or \"make these shorter\".")
                .font(.appFootnote)
        }
    }

    // MARK: - Step two

    private var pasteSection: some View {
        Section {
            TextEditor(text: $pasted)
                .font(.system(.footnote, design: .monospaced))
                .frame(minHeight: 130)
                .overlay(alignment: .topLeading) {
                    if pasted.isEmpty {
                        Text("Paste the assistant's whole reply here")
                            .font(.appFootnote)
                            .foregroundStyle(SignagePalette.concrete.color)
                            .padding(.top, 8)
                            .padding(.leading, 5)
                            .allowsHitTesting(false)
                    }
                }

            Button {
                if let clipboard = UIPasteboard.general.string {
                    pasted = clipboard
                    review()
                } else {
                    errorMessage = "There is nothing on the clipboard to paste."
                }
            } label: {
                Label("Paste from clipboard", systemImage: "doc.on.clipboard.fill")
                    .font(.appHeadline)
            }

            Button {
                review()
            } label: {
                Label("Check it", systemImage: "checkmark.circle")
                    .font(.appHeadline)
            }
            .disabled(pasted.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        } header: {
            PlatformHeader(text: "Step 2", systemIcon: "2.circle", tint: SignagePalette.diversion)
        } footer: {
            Text("Extra words around the JSON are fine — they get ignored.")
                .font(.appFootnote)
        }
    }

    // MARK: - Step three

    private var reviewSection: some View {
        Section {
            ForEach(changes) { change in
                HStack(spacing: 12) {
                    SignPlate(
                        systemIcon: change.badge.systemIcon,
                        emoji: change.badge.emoji,
                        tint: BadgeColor.sign(named: change.badge.colorName),
                        size: 38
                    )

                    VStack(alignment: .leading, spacing: 2) {
                        Text(change.badge.label)
                            .font(.appHeadline)
                        Text(change.badge.displayText)
                            .font(.appFootnote)
                            .foregroundStyle(SignagePalette.concrete.color)
                            .lineLimit(2)
                    }

                    Spacer()

                    Text(tag(for: change.kind))
                        .font(.appCaption)
                        .kerning(0.8)
                        .foregroundStyle(tint(for: change.kind).readableForeground)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule().fill(tint(for: change.kind).color)
                        )
                }
                .padding(.vertical, 4)
                .accessibilityElement(children: .combine)
            }
        } header: {
            PlatformHeader(text: "Step 3 — what will change", systemIcon: "3.circle", tint: SignagePalette.routeGreen)
        } footer: {
            Text(summary)
                .font(.appFootnote)
        }
    }

    private var summary: String {
        let added = changes.filter { $0.kind == .added }.count
        let updated = changes.filter { $0.kind == .updated }.count
        var parts: [String] = []
        if added > 0 { parts.append("\(added) new") }
        if updated > 0 { parts.append("\(updated) changed") }
        if parts.isEmpty { return "Nothing would change. Your badges stay as they are." }
        return "Press Save to keep " + parts.joined(separator: " and ") + "."
    }

    private func tag(for kind: BadgeTransfer.ChangeKind) -> String {
        switch kind {
        case .added: return "NEW"
        case .updated: return "CHANGED"
        case .unchanged: return "SAME"
        }
    }

    private func tint(for kind: BadgeTransfer.ChangeKind) -> SignColor {
        switch kind {
        case .added: return SignagePalette.routeGreen
        case .updated: return SignagePalette.amber
        case .unchanged: return SignagePalette.concrete
        }
    }

    // MARK: - Actions

    private func review() {
        do {
            let incoming = try BadgeTransfer.parse(pasted)
            let outcome = BadgeTransfer.merge(incoming: incoming, into: store.badges)
            merged = outcome.result
            changes = outcome.changes
        } catch {
            changes = []
            merged = []
            errorMessage = error.localizedDescription
        }
    }

    private func apply() {
        // `replaceAll` refuses an empty set, so a parse that somehow produced
        // nothing cannot wipe the library here.
        if store.replaceAll(merged) {
            dismiss()
        } else {
            errorMessage = "That would have left you with no badges, so nothing was saved."
        }
    }
}

#Preview {
    NavigationStack { ImportBadgesView() }
}

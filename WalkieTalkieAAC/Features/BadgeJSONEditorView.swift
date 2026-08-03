//
//  BadgeJSONEditorView.swift
//  Walkie Talkie AAC
//
//  The whole badge set as editable text.
//
//  This is the escape hatch: a speech therapist setting a phone up for
//  somebody, or a user moving their vocabulary between devices, can see and
//  change everything at once rather than tapping through an editor nine
//  times. It is also what makes "the app is a JSON file" true rather than an
//  implementation detail.
//

import SwiftUI

struct BadgeJSONEditorView: View {
    @State private var text = ""
    @State private var errorMessage: String?
    @State private var showingRestoreConfirmation = false

    @Environment(\.dismiss) private var dismiss
    private let store = BadgeStore.shared

    var body: some View {
        VStack(spacing: 0) {
            if let errorMessage {
                Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                    .font(.appFootnote)
                    .foregroundStyle(SignagePalette.signalRed.readableForeground)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(SignagePalette.signalRed.color)
            }

            TextEditor(text: $text)
                .font(.system(.footnote, design: .monospaced))
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding(.horizontal, 8)
        }
        .signageSurface(chevrons: false)
        .navigationTitle("Badges as JSON")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        UIPasteboard.general.string = text
                    } label: {
                        Label("Copy all", systemImage: "doc.on.doc")
                    }
                    Button {
                        if let clipboard = UIPasteboard.general.string {
                            text = clipboard
                        }
                    } label: {
                        Label("Paste over", systemImage: "doc.on.clipboard")
                    }
                    Divider()
                    Button(role: .destructive) {
                        showingRestoreConfirmation = true
                    } label: {
                        Label("Restore starting badges", systemImage: "arrow.counterclockwise")
                    }
                } label: {
                    Label("More", systemImage: "ellipsis.circle")
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { save() }
                    .fontWeight(.semibold)
            }
        }
        .confirmationDialog(
            "Replace your badges with the starting set?",
            isPresented: $showingRestoreConfirmation,
            titleVisibility: .visible
        ) {
            Button("Restore", role: .destructive) {
                store.restoreDefaults()
                text = BadgeTransfer.exportJSON(store.badges)
                errorMessage = nil
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Any badges you have written yourself will be removed.")
        }
        .onAppear {
            text = BadgeTransfer.exportJSON(store.badges)
        }
    }

    private func save() {
        do {
            let badges = try BadgeTransfer.parse(text)
            // The same empty guard as everywhere else. Saving `[]` from here
            // would be a very easy way to lose everything.
            if store.replaceAll(badges) {
                dismiss()
            } else {
                errorMessage = "That would leave you with no badges."
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    NavigationStack { BadgeJSONEditorView() }
}

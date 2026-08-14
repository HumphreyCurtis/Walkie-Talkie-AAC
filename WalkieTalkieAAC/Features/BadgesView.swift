//
//  BadgesView.swift
//  Walkie Talkie AAC
//
//  The badge list. Tapping a row shows the badge; everything else — editing,
//  reordering, importing — sits behind a deliberate second action, so the
//  common case stays one tap.
//

import SwiftUI

struct BadgesView: View {
    @State private var store = BadgeStore.shared
    @State private var showingNewBadge = false
    @State private var showingImport = false
    @State private var showingJSON = false
    @State private var editingBadge: Badge?
    @State private var badgeToDelete: Badge?
    @State private var editMode: EditMode = .inactive

    private func row(for badge: Badge) -> some View {
        SignageRow(
            title: badge.label,
            subtitle: badge.displayText,
            systemIcon: badge.systemIcon,
            emoji: badge.emoji,
            tint: BadgeColor.sign(named: badge.colorName)
        )
    }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 3) {
                    PlatformHeader(
                        text: "Your badges",
                        systemIcon: "rectangle.stack.fill",
                        tint: SignagePalette.motorway
                    )

                    Text("Swipe right to delete  •  Swipe left to edit or speak")
                        .font(.appCaption)
                        .foregroundStyle(SignagePalette.concrete.color)
                        .padding(.bottom, 3)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .signageHeaderRow()

                ForEach(store.badges) { badge in
                    Group {
                        if editMode.isEditing {
                            // In edit mode a tap opens the editor rather than
                            // the outward display — that is what someone who
                            // just pressed "Edit" is trying to do.
                            Button {
                                editingBadge = badge
                            } label: {
                                row(for: badge)
                            }
                            .buttonStyle(.plain)
                        } else {
                            NavigationLink {
                                DisplayView(badge: badge)
                            } label: {
                                row(for: badge)
                            }
                        }
                    }
                    .signageRowStyle()
                    // Delete sits on the leading swipe. `allowsFullSwipe` is
                    // off so a fast swipe cannot delete outright: there is no
                    // undo, these are messages the user wrote themselves, and
                    // several co-designers were operating the phone
                    // one-handed.
                    .swipeActions(edge: .leading, allowsFullSwipe: false) {
                        Button {
                            badgeToDelete = badge
                        } label: {
                            Label("Delete", systemImage: "trash.fill")
                        }
                        .tint(SignagePalette.signalRed.color)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button {
                            editingBadge = badge
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(SignagePalette.concrete.color)

                        Button {
                            Speaker.shared.speak(badge.displayText, languageCode: badge.languageCode)
                        } label: {
                            Label("Speak", systemImage: "speaker.wave.2.fill")
                        }
                        .tint(SignagePalette.motorway.color)
                    }
                }
                .onDelete { store.delete(at: $0) }
                .onMove { store.move(from: $0, to: $1) }
            } footer: {
                Text("Tap a badge to show it.")
                    .signageFooter()
            }

            Section {
                PlatformHeader(
                    text: "Add a lot at once",
                    systemIcon: "square.and.arrow.down",
                    tint: SignagePalette.diversion
                )
                .signageHeaderRow()

                Button {
                    showingImport = true
                } label: {
                    SignageRow(
                        title: "Write badges with AI",
                        subtitle: "Copy a prompt, paste the reply back",
                        systemIcon: "sparkles",
                        tint: SignagePalette.diversion
                    )
                }
                .buttonStyle(.plain)
                .signageRowStyle()

                Button {
                    showingJSON = true
                } label: {
                    SignageRow(
                        title: "Edit as JSON",
                        subtitle: "See and change the whole set at once",
                        systemIcon: "curlybraces",
                        tint: SignagePalette.terminal
                    )
                }
                .buttonStyle(.plain)
                .signageRowStyle()
            }
        }
        .listStyle(.plain)
        .signageContentWidth()
        .signageSurface()
        .environment(\.editMode, $editMode)
        .navigationTitle("Badges")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingNewBadge = true
                } label: {
                    Label("New badge", systemImage: "plus")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                // "Edit" rather than "Reorder": the mode now also opens a
                // badge for editing on tap, alongside reordering and delete.
                Button(editMode.isEditing ? "Done" : "Edit") {
                    withAnimation {
                        editMode = editMode.isEditing ? .inactive : .active
                    }
                }
            }
        }
        // Deleting is irreversible and the text is the user's own, so it
        // confirms and names the badge rather than vanishing on a swipe.
        .confirmationDialog(
            badgeToDelete.map { "Delete “\($0.label)”?" } ?? "Delete badge?",
            isPresented: Binding(
                get: { badgeToDelete != nil },
                set: { if !$0 { badgeToDelete = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let badgeToDelete { store.delete(badgeToDelete) }
                badgeToDelete = nil
            }
            Button("Keep", role: .cancel) { badgeToDelete = nil }
        } message: {
            Text(badgeToDelete?.displayText ?? "")
        }
        .sheet(isPresented: $showingNewBadge) {
            NavigationStack { BadgeEditorView(badge: nil) }
        }
        .sheet(item: $editingBadge) { badge in
            NavigationStack { BadgeEditorView(badge: badge) }
        }
        .sheet(isPresented: $showingImport) {
            NavigationStack { ImportBadgesView() }
        }
        .sheet(isPresented: $showingJSON) {
            NavigationStack { BadgeJSONEditorView() }
        }
    }

}

#Preview {
    NavigationStack { BadgesView() }
}

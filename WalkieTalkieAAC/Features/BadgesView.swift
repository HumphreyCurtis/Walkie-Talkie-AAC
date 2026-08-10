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
    @State private var editMode: EditMode = .inactive

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 3) {
                    PlatformHeader(
                        text: "Your badges",
                        systemIcon: "rectangle.stack.fill",
                        tint: SignagePalette.motorway
                    )

                    Text("Swipe left to edit  •  Swipe right to speak")
                        .font(.appCaption)
                        .foregroundStyle(SignagePalette.concrete.color)
                        .padding(.bottom, 3)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .signageHeaderRow()

                ForEach(store.badges) { badge in
                    NavigationLink {
                        DisplayView(badge: badge)
                    } label: {
                        SignageRow(
                            title: badge.label,
                            subtitle: badge.displayText,
                            systemIcon: badge.systemIcon,
                            emoji: badge.emoji,
                            tint: BadgeColor.sign(named: badge.colorName)
                        )
                    }
                    .signageRowStyle()
                    // Speaking is the action most likely to be wanted in a
                    // hurry, so it sits on the leading swipe where it can be
                    // reached without opening anything.
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        Button {
                            Speaker.shared.speak(badge.displayText, languageCode: badge.languageCode)
                        } label: {
                            Label("Speak", systemImage: "speaker.wave.2.fill")
                        }
                        .tint(SignagePalette.motorway.color)
                    }
                    .swipeActions(edge: .trailing) {
                        Button {
                            editingBadge = badge
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(SignagePalette.concrete.color)
                    }
                }
                .onDelete { store.delete(at: $0) }
                .onMove { store.move(from: $0, to: $1) }
            } footer: {
                Text("Tap a badge to show it.")
                    .signageFooter()
            }

            Section {
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
            } header: {
                PlatformHeader(
                    text: "Add a lot at once",
                    systemIcon: "square.and.arrow.down",
                    tint: SignagePalette.diversion
                )
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
                Button(editMode.isEditing ? "Done" : "Reorder") {
                    withAnimation {
                        editMode = editMode.isEditing ? .inactive : .active
                    }
                }
            }
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

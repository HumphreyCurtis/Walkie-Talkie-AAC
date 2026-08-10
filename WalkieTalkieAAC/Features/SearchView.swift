//
//  SearchView.swift
//  Walkie Talkie AAC
//
//  Look a word up, mid-conversation, and show the result to the person you
//  are talking to.
//
//  Pictures first. For someone who cannot retrieve a word, an image search is
//  often faster than a definition, and the result can be held up as a
//  reference — the study's participants used the phone as a prop to point at
//  far more often than they used it to speak.
//
//  Everything opens in Safari. The app itself makes no network requests, so
//  each site's own privacy policy applies once you leave.
//

import SwiftUI

struct SearchView: View {
    private struct Source: Identifiable {
        let id = UUID()
        let title: String
        let subtitle: String
        let systemIcon: String
        let tint: SignColor
        let template: String
    }

    @State private var query = ""
    @FocusState private var isFocused: Bool

    // %@ is replaced with the percent-encoded query.
    private let sources: [Source] = [
        Source(
            title: "Pictures",
            subtitle: "Show someone what you mean",
            systemIcon: "photo.stack.fill",
            tint: SignagePalette.terminal,
            template: "https://www.google.com/search?tbm=isch&q=%@"
        ),
        Source(
            title: "Maps",
            subtitle: "Find a place or point at one",
            systemIcon: "map.fill",
            tint: SignagePalette.motorway,
            template: "https://maps.apple.com/?q=%@"
        ),
        Source(
            title: "Dictionary",
            subtitle: "What a word means",
            systemIcon: "character.book.closed.fill",
            tint: SignagePalette.diversion,
            template: "https://www.collinsdictionary.com/dictionary/english/%@"
        ),
        Source(
            title: "Wikipedia",
            subtitle: "Read about it",
            systemIcon: "book.fill",
            tint: SignagePalette.tourist,
            template: "https://en.wikipedia.org/wiki/Special:Search?search=%@"
        ),
        Source(
            title: "Video",
            subtitle: "Watch how it works",
            systemIcon: "play.rectangle.fill",
            tint: SignagePalette.signalRed,
            template: "https://www.youtube.com/results?search_query=%@"
        ),
        Source(
            title: "Web",
            subtitle: "Search everything",
            systemIcon: "globe",
            tint: SignagePalette.routeGreen,
            template: "https://www.google.com/search?q=%@"
        ),
    ]

    private var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        List {
            Section {
                PlatformHeader(
                    text: "Search",
                    systemIcon: "magnifyingglass",
                    tint: SignagePalette.terminal
                )
                .signageHeaderRow()

                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(SignagePalette.concrete.color)

                    TextField("What are you looking for?", text: $query)
                        .font(.appTitle3)
                        .focused($isFocused)
                        .submitLabel(.search)
                        .autocorrectionDisabled(false)

                    if !query.isEmpty {
                        Button {
                            query = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(SignagePalette.concrete.color)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Clear")
                    }
                }
                .padding(.vertical, 6)
                .signageRowStyle()

                if !trimmedQuery.isEmpty {
                    Button {
                        Speaker.shared.speak(trimmedQuery)
                    } label: {
                        SignageRow(
                            title: "Say it out loud",
                            subtitle: trimmedQuery,
                            systemIcon: "speaker.wave.3.fill",
                            tint: SignagePalette.concrete
                        )
                    }
                    .buttonStyle(.plain)
                    .signageRowStyle()
                }
            }

            Section {
                ForEach(sources) { source in
                    Button {
                        open(source)
                    } label: {
                        SignageRow(
                            title: source.title,
                            subtitle: source.subtitle,
                            systemIcon: source.systemIcon,
                            tint: source.tint
                        )
                    }
                    .buttonStyle(.plain)
                    .signageRowStyle()
                    .disabled(trimmedQuery.isEmpty)
                    .opacity(trimmedQuery.isEmpty ? 0.45 : 1)
                }
            } header: {
                PlatformHeader(
                    text: "Look it up in",
                    systemIcon: "arrow.up.forward.app",
                    tint: SignagePalette.terminal
                )
            } footer: {
                Text("These open in Safari. This app does not send anything anywhere on its own.")
                    .signageFooter()
            }
        }
        .listStyle(.plain)
        .signageContentWidth()
        .signageSurface()
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func open(_ source: Source) {
        // Percent-encoding, not space-stripping. The old build mashed
        // "guide dog" into "guidedog" and got nothing back.
        guard let encoded = trimmedQuery.addingPercentEncoding(
                withAllowedCharacters: .urlQueryAllowed
              ),
              let url = URL(string: source.template.replacingOccurrences(of: "%@", with: encoded))
        else { return }

        isFocused = false
        UIApplication.shared.open(url)
    }
}

#Preview {
    NavigationStack { SearchView() }
}

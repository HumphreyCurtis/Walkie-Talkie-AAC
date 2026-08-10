//
//  ContentView.swift
//  Walkie Talkie AAC
//
//  The main menu, laid out as a station directory: one row per destination,
//  each with a coloured plate.
//
//  A list rather than the grid of tiles the research prototype used. Rows
//  give every destination the same full-width target, keep the labels
//  readable at accessibility text sizes, and reflow instead of shrinking. The
//  colour and the position of a row never change, so the route to a screen
//  can be remembered as "second, red" without reading anything — which is the
//  point, for an app used by people who find reading hard.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) private var scheme

    private enum Feature: Hashable {
        case badges, symbolSpeak, photoToSpeech
        case search, settings, about
    }

    private struct Destination: Identifiable {
        let id = UUID()
        let feature: Feature
        let title: String
        let subtitle: String
        let systemIcon: String
        let tint: SignColor
    }

    private let speaking: [Destination] = [
        Destination(
            feature: .badges,
            title: "Badges",
            subtitle: "Show or speak a message in the words you choose",
            systemIcon: "rectangle.stack.fill",
            tint: SignagePalette.motorway
        ),
        Destination(
            feature: .symbolSpeak,
            title: "Symbol Speak",
            subtitle: "Speak, and see the picture for the word",
            systemIcon: "rectangle.3.group.bubble.fill",
            tint: SignagePalette.diversion
        ),
        Destination(
            feature: .photoToSpeech,
            title: "Photo to Speech",
            subtitle: "Point the camera at something to find its word",
            systemIcon: "camera.viewfinder",
            tint: SignagePalette.roadworks
        ),
    ]

    private let everydayLife: [Destination] = [
        Destination(
            feature: .search,
            title: "Search",
            subtitle: "Look up a word in pictures, maps or another language",
            systemIcon: "magnifyingglass",
            tint: SignagePalette.terminal
        ),
    ]

    private let app: [Destination] = [
        Destination(
            feature: .settings,
            title: "Settings",
            subtitle: "Voice, speed and how badges face",
            systemIcon: "gearshape.fill",
            tint: SignagePalette.concrete
        ),
        Destination(
            feature: .about,
            title: "About",
            subtitle: "The research, and ways to support the app",
            systemIcon: "info.circle.fill",
            tint: SignagePalette.tourist
        ),
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                homeHeader

                List {
                    Section {
                        PlatformHeader(
                            text: "Say something",
                            systemIcon: "dot.radiowaves.left.and.right",
                            tint: SignagePalette.motorway
                        )
                        .signageHeaderRow()

                        ForEach(speaking) { row(for: $0) }
                    }

                    Section {
                        PlatformHeader(
                            text: "Find the words",
                            systemIcon: "character.book.closed.fill",
                            tint: SignagePalette.routeGreen
                        )
                        .signageHeaderRow()

                        ForEach(everydayLife) { row(for: $0) }
                    }

                    Section {
                        PlatformHeader(
                            text: "This app",
                            systemIcon: "app.badge",
                            tint: SignagePalette.concrete
                        )
                        .signageHeaderRow()

                        ForEach(app) { row(for: $0) }
                    }
                }
                .listStyle(.plain)
                .signageContentWidth()
                .signageSurface()
            }
            .background(SignagePalette.surface(scheme).ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var homeHeader: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("Walkie Talkie AAC")
                .font(.appLargeTitle)
                .foregroundStyle(SignagePalette.ink(scheme))
            Text("Show words. Speak them aloud.")
                .font(.appSubheadline)
                .foregroundStyle(SignagePalette.concrete.color)
        }
        .frame(maxWidth: 640, alignment: .leading)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 14)
        .background(SignagePalette.surface(scheme))
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(SignagePalette.concrete.color.opacity(0.25))
                .frame(height: 1)
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }

    private func row(for destination: Destination) -> some View {
        NavigationLink {
            view(for: destination.feature)
        } label: {
            SignageRow(
                title: destination.title,
                subtitle: destination.subtitle,
                systemIcon: destination.systemIcon,
                tint: destination.tint
            )
        }
        .signageRowStyle()
    }

    @ViewBuilder
    private func view(for feature: Feature) -> some View {
        switch feature {
        case .badges: BadgesView()
        case .symbolSpeak: SymbolSpeakView()
        case .photoToSpeech: PhotoToSpeechView()
        case .search: SearchView()
        case .settings: SettingsView()
        case .about: AboutView()
        }
    }
}

#Preview {
    ContentView()
}

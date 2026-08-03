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
    private enum Feature: Hashable {
        case badges, attention, symbolSpeak, photoToSpeech
        case sunflower, search, aphasia, settings, about
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
            subtitle: "Show a message to the person in front of you",
            systemIcon: "rectangle.stack.fill",
            tint: SignagePalette.motorway
        ),
        Destination(
            feature: .attention,
            title: "Attention",
            subtitle: "A large, urgent display when you need to be noticed",
            systemIcon: "exclamationmark.triangle.fill",
            tint: SignagePalette.signalRed
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
            feature: .sunflower,
            title: "Slow Sunflower",
            subtitle: "A quiet display for a hidden disability lanyard",
            systemIcon: "camera.macro",
            tint: SignagePalette.amber
        ),
        Destination(
            feature: .search,
            title: "Search",
            subtitle: "Look a word up in pictures, maps or a dictionary",
            systemIcon: "magnifyingglass",
            tint: SignagePalette.terminal
        ),
        Destination(
            feature: .aphasia,
            title: "Aphasia Info",
            subtitle: "Explain aphasia, so you do not have to",
            systemIcon: "person.fill.questionmark",
            tint: SignagePalette.routeGreen
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
            List {
                Section {
                    ForEach(speaking) { row(for: $0) }
                } header: {
                    PlatformHeader(
                        text: "Say something",
                        systemIcon: "dot.radiowaves.left.and.right",
                        tint: SignagePalette.motorway
                    )
                }

                Section {
                    ForEach(everydayLife) { row(for: $0) }
                } header: {
                    PlatformHeader(
                        text: "Out and about",
                        systemIcon: "figure.walk",
                        tint: SignagePalette.routeGreen
                    )
                }

                Section {
                    ForEach(app) { row(for: $0) }
                } header: {
                    PlatformHeader(
                        text: "This app",
                        systemIcon: "app.badge",
                        tint: SignagePalette.concrete
                    )
                }
            }
            .listStyle(.plain)
            .signageContentWidth()
            .signageSurface()
            .navigationTitle("Walkie Talkie")
            .navigationBarTitleDisplayMode(.large)
        }
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
        case .attention: AttentionView()
        case .symbolSpeak: SymbolSpeakView()
        case .photoToSpeech: PhotoToSpeechView()
        case .sunflower: SunflowerView()
        case .search: SearchView()
        case .aphasia: AphasiaInfoView()
        case .settings: SettingsView()
        case .about: AboutView()
        }
    }
}

#Preview {
    ContentView()
}

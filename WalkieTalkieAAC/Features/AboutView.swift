//
//  AboutView.swift
//  Walkie Talkie AAC
//
//  Where the app came from, and how to support the people it came from.
//
//  Aphasia Re-Connect ran the workshops the app was designed in, and their
//  members did the designing. The donation link is here because of that, not
//  as a generic good cause.
//

import SwiftUI

struct AboutView: View {
    private let tint = SignagePalette.tourist

    private var version: String {
        let short = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
        return "\(short ?? "1.0") (\(build ?? "1"))"
    }

    var body: some View {
        List {
            Section {
                Link(destination: AppLinks.researchPaper) {
                    SignageRow(
                        title: "Read the research",
                        subtitle: "Breaking Badge, CHI 2024",
                        systemIcon: "doc.text.fill",
                        tint: tint
                    )
                }
                .buttonStyle(.plain)
                .signageRowStyle()

                Link(destination: AppLinks.sisterApp) {
                    SignageRow(
                        title: "Watch Your Language AAC",
                        subtitle: "The companion app, for Apple Watch",
                        systemIcon: "applewatch",
                        tint: tint
                    )
                }
                .buttonStyle(.plain)
                .signageRowStyle()
            } header: {
                PlatformHeader(text: "Research", systemIcon: "book.closed.fill", tint: tint)
            } footer: {
                Text("Designed with and by people with aphasia, in workshops run with Aphasia Re-Connect.")
                    .signageFooter()
            }

            Section {
                Link(destination: AppLinks.donate) {
                    SignageRow(
                        title: "Donate to Aphasia Re-Connect",
                        subtitle: "The charity this was designed with",
                        systemIcon: "heart.circle.fill",
                        tint: SignagePalette.signalRed
                    )
                }
                .buttonStyle(.plain)
                .signageRowStyle()

                Link(destination: AppLinks.sponsor) {
                    SignageRow(
                        title: "Sponsor development",
                        subtitle: "Help keep the app going",
                        systemIcon: "heart.fill",
                        tint: SignagePalette.diversion
                    )
                }
                .buttonStyle(.plain)
                .signageRowStyle()
            } header: {
                PlatformHeader(text: "Support", systemIcon: "hands.clap.fill", tint: tint)
            } footer: {
                Text("The app is free and always will be. Aphasia Re-Connect is UK registered charity \(AppLinks.charityNumber).")
                    .signageFooter()
            }

            Section {
                Text("Walkie Talkie turns your phone into a sign. Show a message to the person you are talking to in type that is big enough to read at a glance, whether speech is difficult or you use different languages.")
                    .font(.appBody)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 14)
                    .signageRowStyle()

                Text("It supports a conversation without taking it over. Nothing speaks unless you press it, and every badge uses the words and language you choose.")
                    .font(.appBody)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 14)
                    .signageRowStyle()
            } header: {
                PlatformHeader(text: "What this is", systemIcon: "info.circle.fill", tint: tint)
            }

            Section {
                ForEach(AphasiaInfo.explainers, id: \.self) { line in
                    AboutSpeakableRow(text: line, tint: SignagePalette.routeGreen)
                        .signageRowStyle()
                }
            } header: {
                PlatformHeader(
                    text: "What is aphasia?",
                    systemIcon: "person.fill.questionmark",
                    tint: SignagePalette.routeGreen
                )
            } footer: {
                Text("Tap a sentence to say it out loud.")
                    .signageFooter()
            }

            Section {
                ForEach(Array(AphasiaInfo.tips.enumerated()), id: \.offset) { index, tip in
                    AboutSpeakableRow(
                        text: tip,
                        prefix: "\(index + 1).",
                        tint: SignagePalette.routeGreen
                    )
                    .signageRowStyle()
                }

                Button {
                    Speaker.shared.speak(AphasiaInfo.tipsSpokenText)
                } label: {
                    SignageRow(
                        title: "Say all of them",
                        systemIcon: "speaker.wave.3.fill",
                        tint: SignagePalette.routeGreen
                    )
                }
                .buttonStyle(.plain)
                .signageRowStyle()
            } header: {
                PlatformHeader(
                    text: "How to talk with me",
                    systemIcon: "bubble.left.and.bubble.right.fill",
                    tint: SignagePalette.routeGreen
                )
            }

            Section {
                Link(destination: AphasiaInfo.learnMoreURL) {
                    SignageRow(
                        title: "Read about aphasia",
                        subtitle: "Stroke Association",
                        systemIcon: "safari.fill",
                        tint: SignagePalette.routeGreen
                    )
                }
                .buttonStyle(.plain)
                .signageRowStyle()

                Link(destination: AphasiaInfo.reconnectURL) {
                    SignageRow(
                        title: "Aphasia Re-Connect",
                        subtitle: "Groups, support and community",
                        systemIcon: "person.3.fill",
                        tint: SignagePalette.routeGreen
                    )
                }
                .buttonStyle(.plain)
                .signageRowStyle()
            } header: {
                PlatformHeader(
                    text: "Aphasia support",
                    systemIcon: "arrow.up.forward.app",
                    tint: SignagePalette.routeGreen
                )
            }

            Section {
                HStack {
                    Text("Version")
                        .font(.appBody)
                    Spacer()
                    Text(version)
                        .font(.appFootnote)
                        .foregroundStyle(SignagePalette.concrete.color)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 14)
                .signageRowStyle()
            } footer: {
                Text("Your badges stay on this phone. There is no account, no server and no tracking.")
                    .signageFooter()
            }
        }
        .listStyle(.plain)
        .signageContentWidth()
        .signageSurface()
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct AboutSpeakableRow: View {
    let text: String
    var prefix: String?
    let tint: SignColor

    var body: some View {
        Button {
            Speaker.shared.speak(text)
        } label: {
            HStack(spacing: 10) {
                if let prefix {
                    Text(prefix)
                        .font(.appHeadline)
                        .foregroundStyle(tint.color)
                        .frame(minWidth: 22, alignment: .leading)
                }

                Text(text)
                    .font(.appBody)
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "speaker.wave.2")
                    .font(.appFootnote)
                    .foregroundStyle(SignagePalette.concrete.color)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
            .frame(minHeight: 56)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(text)
        .accessibilityHint("Double tap to say this out loud")
    }
}

#Preview {
    NavigationStack { AboutView() }
}

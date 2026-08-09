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
                Text("Walkie Talkie turns your phone into a sign. Wear it on a lanyard, facing outward, and show a message to the person you are talking to in type that is big enough to read at a glance.")
                    .font(.appBody)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 14)
                    .signageRowStyle()

                Text("It is a safety net for when talking breaks down, not a replacement for your voice. Nothing speaks unless you press it.")
                    .font(.appBody)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 14)
                    .signageRowStyle()
            } header: {
                PlatformHeader(text: "What this is", systemIcon: "info.circle.fill", tint: tint)
            }

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
                PlatformHeader(text: "Where it came from", systemIcon: "book.closed.fill", tint: tint)
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

#Preview {
    NavigationStack { AboutView() }
}

//
//  AphasiaInfoView.swift
//  Walkie Talkie AAC
//
//  Explaining aphasia, so the wearer does not have to.
//
//  Every line here is tappable and speaks. That is the point of the page: it
//  is not reference material for the wearer, who already knows what aphasia
//  is. It is something to hand to a stranger — a shop assistant, a nurse, a
//  ticket inspector — so the explaining is done by the phone rather than by
//  the person who finds explaining hardest.
//
//  The tips are addressed to that stranger, in the second person, because
//  the study's design principle was that the display can teach accessible
//  practice on the wearer's behalf.
//

import SwiftUI

struct AphasiaInfoView: View {
    private let tint = SignagePalette.routeGreen

    var body: some View {
        List {
            Section {
                ForEach(AphasiaInfo.explainers, id: \.self) { line in
                    SpeakableRow(text: line, tint: tint)
                        .signageRowStyle()
                }
            } header: {
                PlatformHeader(
                    text: "What is aphasia?",
                    systemIcon: "person.fill.questionmark",
                    tint: tint
                )
            } footer: {
                Text("Tap a sentence to say it out loud.")
                    .signageFooter()
            }

            Section {
                ForEach(Array(AphasiaInfo.tips.enumerated()), id: \.offset) { index, tip in
                    SpeakableRow(text: tip, prefix: "\(index + 1).", tint: tint)
                        .signageRowStyle()
                }

                Button {
                    Speaker.shared.speak(AphasiaInfo.tipsSpokenText)
                } label: {
                    SignageRow(
                        title: "Say all of them",
                        systemIcon: "speaker.wave.3.fill",
                        tint: tint
                    )
                }
                .buttonStyle(.plain)
                .signageRowStyle()
            } header: {
                PlatformHeader(
                    text: "How to talk with me",
                    systemIcon: "bubble.left.and.bubble.right.fill",
                    tint: tint
                )
            }

            Section {
                Link(destination: AphasiaInfo.learnMoreURL) {
                    SignageRow(
                        title: "Read about aphasia",
                        subtitle: "Stroke Association",
                        systemIcon: "safari.fill",
                        tint: tint
                    )
                }
                .buttonStyle(.plain)
                .signageRowStyle()

                Link(destination: AphasiaInfo.reconnectURL) {
                    SignageRow(
                        title: "Aphasia Re-Connect",
                        subtitle: "Groups, support and community",
                        systemIcon: "person.3.fill",
                        tint: tint
                    )
                }
                .buttonStyle(.plain)
                .signageRowStyle()
            } header: {
                PlatformHeader(
                    text: "Learn more",
                    systemIcon: "arrow.up.forward.app",
                    tint: tint
                )
            } footer: {
                Text("These open in Safari.")
                    .signageFooter()
            }
        }
        .listStyle(.plain)
        .signageContentWidth()
        .signageSurface()
        .navigationTitle("Aphasia")
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// A line of text that speaks itself when tapped.
private struct SpeakableRow: View {
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
    NavigationStack { AphasiaInfoView() }
}

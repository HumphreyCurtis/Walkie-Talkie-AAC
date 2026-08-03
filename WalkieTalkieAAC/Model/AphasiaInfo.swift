//
//  AphasiaInfo.swift
//  Walkie Talkie AAC
//
//  Content only, deliberately separated from the view.
//
//  This page exists because participants in the study asked for it directly:
//  a way to explain what aphasia is to a stranger, without having to explain
//  it themselves in the moment. That is the whole point — the display teaches
//  the communication partner on the wearer's behalf.
//

import Foundation

enum AphasiaInfo {
    /// Short sentences, one idea each. Tappable so the wearer can have the
    /// phone say them rather than doing the explaining.
    static let explainers = [
        "Aphasia is a communication disability",
        "It usually happens after a stroke",
        "It can make it hard to speak, read or write",
        "It does not affect intelligence",
    ]

    /// Addressed to the communication partner, not to the wearer.
    static let tips = [
        "Give me time",
        "Talk slowly",
        "Do not finish my words",
        "Use gesture and drawing",
        "Write things down",
        "Ask one question at a time",
    ]

    static var tipsSpokenText: String {
        "Tips for talking with me: " + tips.joined(separator: ", ")
    }

    static let learnMoreURL = URL(string: "https://www.stroke.org.uk/stroke/effects/aphasia")!
    static let reconnectURL = URL(string: "https://aphasiareconnect.org")!
}

/// Links for the About page.
enum AppLinks {
    static let researchPaper = URL(string: "https://dl.acm.org/doi/10.1145/3613904.3642327")!
    static let sponsor = URL(string: "https://github.com/sponsors/HumphreyCurtis")!
    static let donate = URL(string: "https://aphasiareconnect.org/ways-to-help/donate/")!
    static let sisterApp = URL(string: "https://github.com/HumphreyCurtis/Watch-Your-Language-AAC")!

    /// UK registered charity number, shown alongside the donation link.
    static let charityNumber = "1176125"
}

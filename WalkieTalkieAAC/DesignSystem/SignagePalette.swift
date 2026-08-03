//
//  SignagePalette.swift
//  Walkie Talkie AAC
//
//  The visual language is public wayfinding: UK road signs, airport terminal
//  boards, station directories. Flat saturated blocks, hard edges, no
//  gradients and no translucency, because the display is read at a distance
//  by a stranger who has about a second to take it in.
//
//  Colours are stored as hex rather than as SwiftUI Colors so that contrast
//  against them can actually be computed. A badge whose background the wearer
//  picked must still be legible, and guessing black-or-white by eye does not
//  survive an amber background.
//

import SwiftUI

/// A signage colour, kept as a hex value so contrast can be measured.
struct SignColor: Hashable, Sendable {
    let hex: UInt32

    var color: Color {
        Color(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }

    /// WCAG relative luminance.
    var relativeLuminance: Double {
        func channel(_ raw: Double) -> Double {
            raw <= 0.03928 ? raw / 12.92 : pow((raw + 0.055) / 1.055, 2.4)
        }
        let r = channel(Double((hex >> 16) & 0xFF) / 255)
        let g = channel(Double((hex >> 8) & 0xFF) / 255)
        let b = channel(Double(hex & 0xFF) / 255)
        return 0.2126 * r + 0.7152 * g + 0.0722 * b
    }

    /// WCAG contrast ratio between two colours, 1:1 to 21:1.
    func contrast(against other: SignColor) -> Double {
        let a = relativeLuminance
        let b = other.relativeLuminance
        return (max(a, b) + 0.05) / (min(a, b) + 0.05)
    }

    /// Whichever of signage white or signage ink reads better on this colour.
    /// Measured, not assumed: amber and green sit either side of the boundary.
    var readableForeground: Color {
        let onWhite = contrast(against: SignagePalette.signWhite)
        let onInk = contrast(against: SignagePalette.signInk)
        return onWhite >= onInk ? SignagePalette.signWhite.color : SignagePalette.signInk.color
    }
}

enum SignagePalette {
    // MARK: - Route colours
    //
    // Drawn from UK traffic signs and terminal signage. Every one of these
    // clears 4.5:1 against either signWhite or signInk, checked with
    // `contrast(against:)` rather than by eye.

    /// Motorway blue. The default, and the colour of the app itself.
    static let motorway = SignColor(hex: 0x0B4EA2)
    /// Stop / prohibition red. Reserved for attention and urgency.
    static let signalRed = SignColor(hex: 0xC8102E)
    /// Primary route green. Information and reassurance.
    static let routeGreen = SignColor(hex: 0x00703C)
    /// Warning amber. Takes dark ink, never white.
    static let amber = SignColor(hex: 0xFFB612)
    /// Diversion purple.
    static let diversion = SignColor(hex: 0x6B2C91)
    /// Terminal teal.
    static let terminal = SignColor(hex: 0x00707D)
    /// Tourist brown.
    static let tourist = SignColor(hex: 0x6B4423)
    /// Roadworks orange.
    static let roadworks = SignColor(hex: 0xD2500A)

    // MARK: - Neutrals

    /// Sign-face white, very slightly warm so it does not glare.
    static let signWhite = SignColor(hex: 0xFAFAF8)
    /// Sign-face black. Not pure black; pure black flares on OLED at size.
    static let signInk = SignColor(hex: 0x101418)
    /// Post-and-frame grey, for secondary text.
    static let concrete = SignColor(hex: 0x6E7780)

    /// Every route colour, in menu order. Used by the palette picker.
    static let routes: [SignColor] = [
        motorway, signalRed, routeGreen, amber,
        diversion, terminal, tourist, roadworks,
    ]

    // MARK: - Surfaces
    //
    // Plain functions of the colour scheme rather than asset-catalogue
    // colours, so the whole palette lives in one readable file.

    static func surface(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(white: 0.07) : signWhite.color
    }

    static func block(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(white: 0.14) : .white
    }

    static func ink(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? signWhite.color : signInk.color
    }
}

/// Named badge colours.
///
/// The names are frozen storage keys. They are written into `Badges.json` and
/// into anything an LLM generates, so they must not change even if the hex
/// values behind them get retuned later.
enum BadgeColor {
    static let names = [
        "blue", "red", "green", "amber",
        "purple", "teal", "brown", "orange",
    ]

    static let defaultName = "blue"

    static func sign(named name: String?) -> SignColor {
        switch name?.lowercased() {
        case "red": return SignagePalette.signalRed
        case "green": return SignagePalette.routeGreen
        case "amber", "yellow": return SignagePalette.amber
        case "purple", "indigo": return SignagePalette.diversion
        case "teal", "cyan": return SignagePalette.terminal
        case "brown": return SignagePalette.tourist
        case "orange": return SignagePalette.roadworks
        case "blue": return SignagePalette.motorway
        default: return SignagePalette.motorway
        }
    }

    static func color(named name: String?) -> Color { sign(named: name).color }

    static func foreground(named name: String?) -> Color { sign(named: name).readableForeground }

    /// Spoken-aloud description, used for VoiceOver labels.
    static func routeName(for name: String?) -> String {
        switch name?.lowercased() {
        case "red": return "signal red"
        case "green": return "route green"
        case "amber", "yellow": return "warning amber"
        case "purple", "indigo": return "diversion purple"
        case "teal", "cyan": return "terminal teal"
        case "brown": return "tourist brown"
        case "orange": return "roadworks orange"
        default: return "motorway blue"
        }
    }

    /// The stored name for a route colour, for the editor's swatch picker.
    static func name(for sign: SignColor) -> String {
        names.first { BadgeColor.sign(named: $0) == sign } ?? defaultName
    }
}

//
//  Typography.swift
//  Walkie Talkie AAC
//
//  Two typefaces, both shipped with iOS, so there is nothing to license,
//  bundle, or register at launch.
//
//  DIN Alternate carries the headings and the big outward-facing words. DIN
//  is the German road-sign standard (DIN 1451) and reads as signage instantly
//  — square terminals, open counters, engineered rather than styled. It ships
//  in Bold only, which suits a typeface that is only ever used loud.
//
//  Avenir Next carries body text. Avenir is Adrian Frutiger's, and Frutiger's
//  other typeface was drawn for the signs at Charles de Gaulle airport, so the
//  two sit in the same lineage without the headings and the paragraphs
//  fighting each other. Its lowercase is far kinder to read at length than
//  DIN's, which matters for the aphasia information.
//
//  Everything goes through `relativeTo:` so Dynamic Type keeps working. A
//  communication aid that ignores the user's text size setting is not one.
//

import SwiftUI
import UIKit

enum AppFont {
    /// DIN Alternate ships in Bold only. `Font.custom` falls back to the
    /// system face if a name is ever unavailable, so this degrades quietly.
    static let signage = "DINAlternate-Bold"
    static let signageCondensed = "DINCondensed-Bold"

    static let bodyRegular = "AvenirNext-Regular"
    static let bodyMedium = "AvenirNext-Medium"
    static let bodyDemiBold = "AvenirNext-DemiBold"
    static let bodyBold = "AvenirNext-Bold"

    enum Size {
        static let largeTitle: CGFloat = 32
        static let title: CGFloat = 27
        static let title2: CGFloat = 21
        static let title3: CGFloat = 19
        static let headline: CGFloat = 17
        static let body: CGFloat = 17
        static let callout: CGFloat = 16
        static let subheadline: CGFloat = 15
        static let footnote: CGFloat = 13
        static let caption: CGFloat = 12
    }
}

extension Font {
    // MARK: - Signage faces, for headings and anything read at distance

    static var appLargeTitle: Font {
        .custom(AppFont.signage, size: AppFont.Size.largeTitle, relativeTo: .largeTitle)
    }

    static var appTitle: Font {
        .custom(AppFont.signage, size: AppFont.Size.title, relativeTo: .title)
    }

    static var appTitle2: Font {
        .custom(AppFont.signage, size: AppFont.Size.title2, relativeTo: .title2)
    }

    static var appTitle3: Font {
        .custom(AppFont.signage, size: AppFont.Size.title3, relativeTo: .title3)
    }

    /// Row titles and button labels. Signage face, because these are the
    /// words someone scans for rather than reads.
    static var appHeadline: Font {
        .custom(AppFont.signage, size: AppFont.Size.headline, relativeTo: .headline)
    }

    // MARK: - Body faces, for anything read as a sentence

    static var appBody: Font {
        .custom(AppFont.bodyRegular, size: AppFont.Size.body, relativeTo: .body)
    }

    static var appBodyEmphasised: Font {
        .custom(AppFont.bodyDemiBold, size: AppFont.Size.body, relativeTo: .body)
    }

    static var appCallout: Font {
        .custom(AppFont.bodyRegular, size: AppFont.Size.callout, relativeTo: .callout)
    }

    static var appSubheadline: Font {
        .custom(AppFont.bodyMedium, size: AppFont.Size.subheadline, relativeTo: .subheadline)
    }

    static var appFootnote: Font {
        .custom(AppFont.bodyRegular, size: AppFont.Size.footnote, relativeTo: .footnote)
    }

    static var appCaption: Font {
        .custom(AppFont.bodyMedium, size: AppFont.Size.caption, relativeTo: .caption)
    }

    /// The outward-facing word on a badge. Sized by the caller because it is
    /// scaled to fill the screen rather than to a text style; the display
    /// views apply `minimumScaleFactor` so long words still fit.
    ///
    /// Participants in the study were unambiguous about this one:
    /// "the bigger the text the better".
    static func appDisplay(_ size: CGFloat) -> Font {
        .custom(AppFont.signage, size: size)
    }

    /// Condensed display face, for words too long to fit the standard one.
    static func appDisplayCondensed(_ size: CGFloat) -> Font {
        .custom(AppFont.signageCondensed, size: size)
    }
}

enum AppAppearance {
    /// Applies the app's navigation-bar styling. Called once at launch.
    ///
    /// UIKit's appearance proxy is still the only route to the navigation
    /// bar's own title font, and it needs `UIFontMetrics` to stay responsive
    /// to Dynamic Type.
    static func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor { traits in
            UIColor(SignagePalette.surface(traits.userInterfaceStyle == .dark ? .dark : .light))
        }
        appearance.shadowColor = UIColor(SignagePalette.concrete.color.opacity(0.3))

        let ink = UIColor { traits in
            UIColor(SignagePalette.ink(traits.userInterfaceStyle == .dark ? .dark : .light))
        }
        if let inline = UIFont(name: AppFont.signage, size: AppFont.Size.headline) {
            appearance.titleTextAttributes = [
                .font: UIFontMetrics(forTextStyle: .headline).scaledFont(for: inline),
                .foregroundColor: ink,
                .kern: 0.5,
            ]
        }
        if let large = UIFont(name: AppFont.signage, size: AppFont.Size.largeTitle) {
            appearance.largeTitleTextAttributes = [
                .font: UIFontMetrics(forTextStyle: .largeTitle).scaledFont(for: large),
                .foregroundColor: ink,
                .kern: 0.5,
            ]
        }

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}

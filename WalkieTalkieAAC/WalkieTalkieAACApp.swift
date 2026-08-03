//
//  WalkieTalkieAACApp.swift
//  Walkie Talkie AAC
//
//  A phone worn on a lanyard, turned outward, used as a sign.
//
//  Built from the CHI 2024 study "Breaking Badge: Augmenting Communication
//  with Wearable AAC Smartbadges and Displays" (Curtis, Lau and Neate), and
//  co-designed with people with aphasia through Aphasia Re-Connect.
//

import SwiftUI

@main
struct WalkieTalkieAACApp: App {
    init() {
        AppAppearance.configureNavigationBar()

        // Touch the stores at launch so the badge file is read and seeded
        // before the first screen asks for it.
        _ = BadgeStore.shared
        _ = SettingsStore.shared
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

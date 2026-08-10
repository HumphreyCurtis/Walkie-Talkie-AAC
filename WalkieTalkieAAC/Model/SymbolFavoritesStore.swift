//
//  SymbolFavoritesStore.swift
//  Walkie Talkie AAC
//
//  UserDefaults-backed favourites for the Symbol Library.
//

import Foundation

final class SymbolFavoritesStore: ObservableObject {
    @Published private(set) var favoriteIDs: Set<String> = []

    private static let storageKey = "SymbolFavorites"

    init() {
        if let stored = UserDefaults.standard.stringArray(forKey: Self.storageKey) {
            favoriteIDs = Set(stored)
        }
    }

    func toggle(_ id: String) {
        if favoriteIDs.contains(id) {
            favoriteIDs.remove(id)
        } else {
            favoriteIDs.insert(id)
        }
        UserDefaults.standard.set(Array(favoriteIDs), forKey: Self.storageKey)
        objectWillChange.send()
    }

    func isFavorite(_ id: String) -> Bool {
        favoriteIDs.contains(id)
    }
}
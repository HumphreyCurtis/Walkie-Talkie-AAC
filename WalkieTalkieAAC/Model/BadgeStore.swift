//
//  BadgeStore.swift
//  Walkie Talkie AAC
//
//  Badges live in one readable JSON file in the app's Documents directory.
//  Plain JSON rather than SwiftData or Core Data specifically so that the
//  file can be exported, pasted into a language model, edited, and pasted
//  back — see BadgeTransfer. A schema you can read out loud is a feature
//  here, not a shortcut.
//
//  Nothing leaves the device. There is no account, no server, no sync.
//

import Foundation
import Observation
import UIKit

@Observable
final class BadgeStore {
    static let shared = BadgeStore()

    private(set) var badges: [Badge] = []

    /// Bumped whenever new example badges are added to `BadgeLibrary`.
    /// Existing installs then receive them once, without their own edits
    /// being touched and without re-adding anything they deliberately
    /// deleted more than once.
    private static let currentSeedVersion = 2

    private struct Snapshot: Codable {
        var badges: [Badge]
        var lastModified: Double
        var seedVersion: Int?
    }

    private var lastModified: Double = 0
    private var seedVersion: Int = 0

    private var fileURL: URL {
        URL.documentsDirectory.appendingPathComponent("Badges.json")
    }

    private init() {
        load()
    }

    // MARK: - Loading

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else {
            seedFromDefaults()
            return
        }

        do {
            let snapshot = try JSONDecoder().decode(Snapshot.self, from: data)
            badges = snapshot.badges
            lastModified = snapshot.lastModified
            seedVersion = snapshot.seedVersion ?? 1
            applyNewSeedsIfNeeded()
        } catch {
            // A corrupt file must not present the user with an empty app.
            // The unreadable file is kept alongside rather than overwritten,
            // in case it can be recovered by hand later.
            let salvage = fileURL.deletingPathExtension()
                .appendingPathExtension("corrupt.json")
            try? data.write(to: salvage, options: .atomic)
            seedFromDefaults()
        }
    }

    private func seedFromDefaults() {
        badges = BadgeLibrary.defaults + BadgeLibrary.multilingualExamples
        seedVersion = Self.currentSeedVersion
        save()
    }

    /// Appends example badges introduced since the install was last seeded,
    /// skipping any whose label the user already has.
    private func applyNewSeedsIfNeeded() {
        guard seedVersion < Self.currentSeedVersion else { return }

        let existing = Set(badges.map { $0.label.lowercased() })
        let additions = BadgeLibrary.multilingualExamples
            .filter { !existing.contains($0.label.lowercased()) }

        badges.append(contentsOf: additions)
        seedVersion = Self.currentSeedVersion
        save()
    }

    // MARK: - Editing

    func add(_ badge: Badge) {
        badges.append(badge)
        save()
    }

    func update(_ badge: Badge) {
        guard let index = badges.firstIndex(where: { $0.id == badge.id }) else { return }
        badges[index] = badge
        save()
    }

    func delete(at offsets: IndexSet) {
        // Take the photos with them, or the directory grows forever with
        // files nothing references.
        for index in offsets {
            if let name = badges[index].backgroundImageName {
                try? FileManager.default.removeItem(at: imageURL(named: name))
            }
        }
        badges.remove(atOffsets: offsets)
        save()
    }

    func move(from source: IndexSet, to destination: Int) {
        badges.move(fromOffsets: source, toOffset: destination)
        save()
    }

    /// Wholesale replacement, used by the JSON editor and the AI import.
    ///
    /// Refuses an empty array unless the caller explicitly opts in, so a
    /// mispaste or a model that returns `[]` cannot silently wipe someone's
    /// vocabulary.
    @discardableResult
    func replaceAll(_ newBadges: [Badge], allowingEmpty: Bool = false) -> Bool {
        guard allowingEmpty || !newBadges.isEmpty else { return false }
        badges = newBadges
        save()
        return true
    }

    func restoreDefaults() {
        badges = BadgeLibrary.defaults + BadgeLibrary.multilingualExamples
        save()
    }

    // MARK: - Background photos
    //
    // Photos are written as files next to Badges.json rather than base64'd
    // into it, so the JSON stays small enough to paste into an assistant.

    private var imagesDirectory: URL {
        let url = URL.documentsDirectory.appendingPathComponent("BadgeImages", isDirectory: true)
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    func imageURL(named name: String) -> URL {
        imagesDirectory.appendingPathComponent(name)
    }

    func image(for badge: Badge) -> UIImage? {
        guard let name = badge.backgroundImageName else { return nil }
        return UIImage(contentsOfFile: imageURL(named: name).path)
    }

    /// Stores a photo for a badge and returns the badge with its filename set.
    /// Any previous photo for that badge is removed.
    @discardableResult
    func setImage(_ image: UIImage?, for badge: Badge) -> Badge {
        var updated = badge

        if let existing = badge.backgroundImageName {
            try? FileManager.default.removeItem(at: imageURL(named: existing))
            updated.backgroundImageName = nil
        }

        if let image {
            // Re-encoded as JPEG rather than stored raw: a full-resolution
            // HEIC per badge adds up fast on a device someone is also using
            // for photos.
            let name = "\(badge.id.uuidString).jpg"
            if let data = image.jpegData(compressionQuality: 0.8) {
                try? data.write(to: imageURL(named: name), options: .atomic)
                updated.backgroundImageName = name
            }
        }

        update(updated)
        return updated
    }

    // MARK: - Saving

    private func save() {
        lastModified = Date().timeIntervalSince1970
        let snapshot = Snapshot(
            badges: badges,
            lastModified: lastModified,
            seedVersion: seedVersion
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        guard let data = try? encoder.encode(snapshot) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}

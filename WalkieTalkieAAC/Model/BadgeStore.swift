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
    private static let currentSeedVersion = 4

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
        badges = BadgeLibrary.defaults + [BadgeLibrary.sunflower] + BadgeLibrary.multilingualExamples
        seedVersion = Self.currentSeedVersion
        save()
    }

    /// Appends example badges introduced since the install was last seeded,
    /// skipping any whose label the user already has.
    private func applyNewSeedsIfNeeded() {
        guard seedVersion < Self.currentSeedVersion else { return }

        // Retire starting badges that are no longer shipped.
        //
        // Seeding otherwise only ever adds, so anyone who installed before the
        // set was trimmed keeps all 29 for good — a wall of cards they never
        // chose, on the screen they use most.
        //
        // Matched on label *and* message together, so only untouched seed data
        // goes. Edit a retired badge, even slightly, and it is yours: it stays.
        if seedVersion < 4 {
            let retired = Set(BadgeLibrary.retiredDefaults.map { "\($0.0)|\($0.1)" })
            badges.removeAll { retired.contains("\($0.label)|\($0.displayText)") }
        }

        let existing = Set(badges.map { $0.label.lowercased() })
        let additions = ([BadgeLibrary.sunflower] + BadgeLibrary.multilingualExamples)
            .filter { !existing.contains($0.label.lowercased()) }

        badges.append(contentsOf: additions)

        // Never leave someone with nothing. If they had deleted most of the
        // starting set already, retiring the rest could empty the list.
        if badges.isEmpty {
            badges = BadgeLibrary.defaults + [BadgeLibrary.sunflower] + BadgeLibrary.multilingualExamples
        }

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

    /// Deletes one badge by identity rather than by row offset.
    ///
    /// Swipe actions know the badge, not its index, and looking the index up
    /// at the call site goes wrong the moment the list is filtered or sorted.
    func delete(_ badge: Badge) {
        guard let index = badges.firstIndex(where: { $0.id == badge.id }) else { return }
        delete(at: IndexSet(integer: index))
    }

    func delete(at offsets: IndexSet) {
        // Take the photos with them, or the directory grows forever with
        // files nothing references.
        for index in offsets {
            if let name = badges[index].backgroundImageName,
               let url = imageURL(named: name) {
                try? FileManager.default.removeItem(at: url)
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

        // A whole-library edit can remove badges without going through
        // `delete(at:)`. Clean up only photos that are no longer referenced.
        let retainedImages = Set(newBadges.compactMap(\.backgroundImageName))
        let removedImages = Set(badges.compactMap(\.backgroundImageName))
            .subtracting(retainedImages)
        for name in removedImages {
            if let url = imageURL(named: name) {
                try? FileManager.default.removeItem(at: url)
            }
        }

        badges = newBadges
        save()
        return true
    }

    func restoreDefaults() {
        _ = replaceAll(BadgeLibrary.defaults + [BadgeLibrary.sunflower] + BadgeLibrary.multilingualExamples)
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

    /// Resolves only plain filenames inside `BadgeImages`.
    ///
    /// `backgroundImageName` is Codable and can therefore come from pasted
    /// JSON. Rejecting path components here prevents a malformed value such
    /// as `../Badges.json` from ever being read or deleted outside the image
    /// directory.
    private func imageURL(named name: String) -> URL? {
        let filename = (name as NSString).lastPathComponent
        guard !filename.isEmpty,
              filename != ".",
              filename != "..",
              filename == name
        else { return nil }

        return imagesDirectory.appendingPathComponent(filename, isDirectory: false)
    }

    func image(for badge: Badge) -> UIImage? {
        guard let name = badge.backgroundImageName,
              let url = imageURL(named: name)
        else { return nil }
        return UIImage(contentsOfFile: url.path)
    }

    /// Stores a photo for a badge and returns the badge with its filename set.
    /// Any previous photo for that badge is removed.
    @discardableResult
    func setImage(_ image: UIImage?, for badge: Badge) -> Badge {
        var updated = badge

        if let existing = badge.backgroundImageName {
            if let url = imageURL(named: existing) {
                try? FileManager.default.removeItem(at: url)
            }
            updated.backgroundImageName = nil
        }

        if let image {
            // Re-encoded as JPEG rather than stored raw: a full-resolution
            // HEIC per badge adds up fast on a device someone is also using
            // for photos.
            let name = "\(badge.id.uuidString).jpg"
            if let data = image.jpegData(compressionQuality: 0.8),
               let url = imageURL(named: name) {
                try? data.write(to: url, options: .atomic)
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

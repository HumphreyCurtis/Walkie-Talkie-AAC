//
//  ImageClassifier.swift
//  Walkie Talkie AAC
//
//  Photo to Speech: point the camera at something you cannot find the word
//  for, and the app offers a word.
//
//  Classification runs entirely on-device with a bundled MobileNetV2. No
//  photo leaves the phone, and nothing is uploaded.
//
//  The model is a general-purpose one and it is wrong often enough to matter.
//  Participants noticed both the errors and their accent — "coffee mug"
//  rather than "tea mug". So the interface shows the confidence, offers
//  alternatives rather than a single answer, and never speaks a guess without
//  being asked. The word is a prompt for the wearer, not an announcement.
//

import CoreImage
import CoreML
import SwiftUI
import Vision

struct Classification: Identifiable, Hashable {
    let id = UUID()
    let label: String
    let confidence: Float

    /// The raw labels are comma-separated synonym lists, e.g.
    /// "coffee mug, mug". Only the first is worth showing.
    var primaryWord: String {
        label.split(separator: ",").first
            .map { $0.trimmingCharacters(in: .whitespaces) } ?? label
    }

    var confidencePercentage: String {
        "\(Int((confidence * 100).rounded()))%"
    }
}

@MainActor
final class ImageClassifier: ObservableObject {
    @Published private(set) var results: [Classification] = []
    @Published private(set) var isClassifying = false
    @Published var errorMessage: String?

    /// Loaded once and reused. Rebuilding the Vision model per photo costs
    /// a noticeable pause on older devices, and the study ran on an iPhone SE.
    private lazy var model: VNCoreMLModel? = {
        let configuration = MLModelConfiguration()
        guard let wrapped = try? MobileNetV2(configuration: configuration),
              let model = try? VNCoreMLModel(for: wrapped.model)
        else { return nil }
        return model
    }()

    func classify(_ image: UIImage) {
        guard let model else {
            errorMessage = "The word suggester could not start."
            return
        }
        guard let ciImage = CIImage(image: image) else {
            errorMessage = "That photo could not be read."
            return
        }

        isClassifying = true
        errorMessage = nil
        results = []

        // Off the main actor: Vision on a full-resolution photo blocks for
        // long enough to drop frames otherwise.
        Task.detached(priority: .userInitiated) { [weak self] in
            let request = VNCoreMLRequest(model: model)
            request.imageCropAndScaleOption = .centerCrop

            let orientation = CGImagePropertyOrientation(image.imageOrientation)
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)

            do {
                try handler.perform([request])
                let observations = (request.results as? [VNClassificationObservation]) ?? []
                let top = observations.prefix(3).map {
                    Classification(label: $0.identifier, confidence: $0.confidence)
                }
                await self?.finish(with: Array(top), error: nil)
            } catch {
                await self?.finish(with: [], error: "That photo could not be recognised.")
            }
        }
    }

    private func finish(with results: [Classification], error: String?) {
        self.results = results
        self.errorMessage = error
        self.isClassifying = false
    }

    func clear() {
        results = []
        errorMessage = nil
    }
}

private extension CGImagePropertyOrientation {
    /// Vision ignores UIImage.imageOrientation, so a photo taken in portrait
    /// arrives rotated and classifies as something else entirely.
    init(_ orientation: UIImage.Orientation) {
        switch orientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        @unknown default: self = .up
        }
    }
}

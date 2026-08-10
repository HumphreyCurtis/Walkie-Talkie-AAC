//
//  PhotoToSpeechView.swift
//  Walkie Talkie AAC
//
//  Point the camera at something you cannot find the word for.
//
//  Word-finding difficulty is the everyday reality of aphasia, and
//  participants recognised this feature immediately — "would help with my
//  word-finding".
//
//  They also caught its limits. The model is general-purpose, trained on
//  American labels, and gets things wrong: "coffee mug" for a tea mug. So
//  this screen offers three candidates rather than one answer, shows how sure
//  it is, and never speaks or displays a guess by itself. The word is a
//  prompt for the wearer to recognise, not a claim about the world.
//
//  Everything runs on the device. No photo is uploaded or kept.
//

import PhotosUI
import SwiftUI

struct PhotoToSpeechView: View {
    @StateObject private var classifier = ImageClassifier()
    @State private var image: UIImage?
    @State private var pickerItem: PhotosPickerItem?
    @State private var showingCamera = false
    @State private var chosen: Classification?

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 18) {
                    photo
                    results
                }
                .padding(20)
                .signageColumn()
                .frame(minHeight: geometry.size.height - 100, alignment: .top)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .safeAreaInset(edge: .bottom) { sourceButtons }
        .signageSurface()
        .navigationTitle("Photo to Speech")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $chosen) { classification in
            DisplayView(
                badge: Badge(
                    label: classification.primaryWord,
                    displayText: classification.primaryWord,
                    systemIcon: "camera.viewfinder",
                    colorName: "orange"
                )
            )
        }
        .fullScreenCover(isPresented: $showingCamera) {
            CameraPicker(image: $image)
                .ignoresSafeArea()
        }
        .onChange(of: pickerItem) { _, item in
            guard let item else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let loaded = UIImage(data: data) {
                    image = loaded
                }
            }
        }
        .onChange(of: image) { _, newImage in
            guard let newImage else { return }
            classifier.classify(newImage)
        }
    }

    // MARK: - Photo

    @ViewBuilder
    private var photo: some View {
        if let image {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 300)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .accessibilityLabel("The photo you took")
        } else {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(SignagePalette.concrete.color.opacity(0.12))
                .frame(maxHeight: .infinity)
                .overlay {
                    VStack(spacing: 12) {
                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 42, weight: .bold))
                        Text("Take a photo of the thing you mean")
                            .font(.appCallout)
                            .multilineTextAlignment(.center)
                    }
                    .foregroundStyle(SignagePalette.concrete.color)
                    .padding(20)
                }
        }
    }

    // MARK: - Results

    @ViewBuilder
    private var results: some View {
        if classifier.isClassifying {
            HStack(spacing: 10) {
                ProgressView()
                Text("Looking…")
                    .font(.appCallout)
                    .foregroundStyle(SignagePalette.concrete.color)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } else if let errorMessage = classifier.errorMessage {
            Text(errorMessage)
                .font(.appCallout)
                .foregroundStyle(SignagePalette.signalRed.color)
                .frame(maxWidth: .infinity, alignment: .leading)
        } else if !classifier.results.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                PlatformHeader(
                    text: "Is it one of these?",
                    systemIcon: "questionmark.circle",
                    tint: SignagePalette.roadworks
                )

                ForEach(classifier.results) { result in
                    resultRow(result)
                }

                Text("The suggester is often wrong. Pick the one that is right, or take another photo.")
                    .font(.appFootnote)
                    .foregroundStyle(SignagePalette.concrete.color)
                    .padding(.top, 2)
            }
        }
    }

    private func resultRow(_ result: Classification) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(result.primaryWord)
                    .font(.appTitle3)
                Text("\(result.confidencePercentage) sure")
                    .font(.appFootnote)
                    .foregroundStyle(SignagePalette.concrete.color)
            }

            Spacer()

            ControlButton(
                systemIcon: "speaker.wave.3.fill",
                label: "Say \(result.primaryWord)",
                tint: SignagePalette.concrete
            ) {
                Speaker.shared.speak(result.primaryWord)
            }

            ControlButton(
                systemIcon: "rectangle.on.rectangle",
                label: "Show \(result.primaryWord) as a badge",
                tint: SignagePalette.roadworks
            ) {
                chosen = result
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(SignagePalette.concrete.color.opacity(0.10))
        )
    }

    // MARK: - Sources

    private var sourceButtons: some View {
        HStack(spacing: 10) {
            PressToTalkButton(
                title: "Camera",
                systemIcon: "camera.fill",
                tint: SignagePalette.roadworks
            ) {
                showingCamera = true
            }

            PhotosPicker(selection: $pickerItem, matching: .images) {
                Image(systemName: "photo.on.rectangle")
                    .font(.system(size: 21, weight: .bold))
                    .foregroundStyle(SignagePalette.concrete.readableForeground)
                    .frame(width: 68, height: 64)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(SignagePalette.concrete.color)
                    )
            }
            .accessibilityLabel("Choose a photo")
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .signageColumn()
        .background(.regularMaterial)
    }
}

#Preview {
    NavigationStack { PhotoToSpeechView() }
}

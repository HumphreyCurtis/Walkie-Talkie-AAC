//
//  SunflowerView.swift
//  Walkie Talkie AAC
//
//  A quiet display to go with a Hidden Disabilities Sunflower lanyard.
//
//  This one is deliberately the opposite of Attention. The sunflower lanyard
//  works by being recognised rather than by being loud, and several
//  co-designers already wore one — the phone hanging next to it should agree
//  with it rather than compete. So: slow drift, no words cycling, no
//  escalation, one short line of text.
//
//  The Hidden Disabilities Sunflower is an independent scheme. This is a
//  companion display for a lanyard someone already has, not a substitute for
//  one and not affiliated with it.
//

import SwiftUI

struct SunflowerView: View {
    private struct Bloom: Identifiable {
        let id = UUID()
        let position: CGPoint   // unit coordinates
        let scale: CGFloat
        let rotation: Double
        let phase: Double
    }

    @State private var blooms: [Bloom] = []
    @State private var rotation: Double = 0

    @AppStorage(SettingsKeys.facesOutward) private var facesOutward = true
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let message = "Please be patient with me"

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                SignagePalette.routeGreen.color.ignoresSafeArea()

                if reduceMotion {
                    // Drifting flowers are exactly the kind of ambient motion
                    // Reduce Motion exists to switch off. The still layout
                    // carries the same meaning.
                    field(in: geometry.size, offset: { _ in .zero })
                } else {
                    TimelineView(.animation) { context in
                        let time = context.date.timeIntervalSinceReferenceDate
                        field(in: geometry.size) { bloom in
                            CGSize(
                                width: sin(time * 0.25 + bloom.phase) * 14,
                                height: cos(time * 0.2 + bloom.phase) * 18
                            )
                        }
                    }
                }

                caption
            }
        }
        .ignoresSafeArea()
        .navigationTitle("Slow Sunflower")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        rotation = (rotation + 180).truncatingRemainder(dividingBy: 360)
                    }
                } label: {
                    Label("Turn around", systemImage: "rotate.right.fill")
                }
            }
        }
        .onAppear {
            rotation = facesOutward ? 180 : 0
            if blooms.isEmpty { blooms = Self.makeBlooms() }
        }
        .onTapGesture {
            Speaker.shared.speak(message)
        }
    }

    private func field(in size: CGSize, offset: @escaping (Bloom) -> CGSize) -> some View {
        ForEach(blooms) { bloom in
            Image("sunflower")
                .resizable()
                .scaledToFill()
                .frame(width: 86 * bloom.scale, height: 86 * bloom.scale)
                .clipShape(Circle())
                .rotationEffect(.degrees(bloom.rotation))
                .position(
                    x: bloom.position.x * size.width,
                    y: bloom.position.y * size.height
                )
                .offset(offset(bloom))
                .opacity(0.9)
        }
        .accessibilityHidden(true)
    }

    private var caption: some View {
        VStack {
            Spacer()
            Text(message)
                .font(.appTitle2)
                .multilineTextAlignment(.center)
                .foregroundStyle(SignagePalette.amber.readableForeground)
                .padding(.horizontal, 22)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(SignagePalette.amber.color)
                )
                .padding(.bottom, 60)
                .rotationEffect(.degrees(rotation))
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(message)
        .accessibilityHint("Double tap to speak")
    }

    /// Scattered once and kept, rather than regenerated per frame — a layout
    /// that reshuffles while you look at it is unsettling, and the study's
    /// whole point here was calm.
    private static func makeBlooms() -> [Bloom] {
        (0..<14).map { index in
            Bloom(
                position: CGPoint(
                    x: .random(in: 0.08...0.92),
                    y: .random(in: 0.08...0.82)
                ),
                scale: .random(in: 0.55...1.35),
                rotation: .random(in: 0...360),
                phase: Double(index) * 0.7
            )
        }
    }
}

#Preview {
    NavigationStack { SunflowerView() }
}

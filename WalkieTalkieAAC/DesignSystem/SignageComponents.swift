//
//  SignageComponents.swift
//  Walkie Talkie AAC
//
//  The shared furniture: sign plates, menu rows, section headers, the big
//  press-to-talk control, and the chevron backdrop.
//
//  Two constraints run through all of it. Targets are large, because several
//  co-designers had hemiplegia and were operating the phone one-handed, and
//  because "bigger buttons" was the single most repeated request in the
//  study. And layouts reflow rather than truncate at accessibility text
//  sizes, because clipped text on a communication aid is a failed sentence.
//

import SwiftUI

// MARK: - Sign plate

/// A square sign plate carrying a symbol or an emoji, in a route colour.
///
/// Square rather than circular: road signage is rectangular, and a rounded
/// square holds a glyph at a larger optical size than a circle of the same
/// footprint.
struct SignPlate: View {
    let systemIcon: String
    var emoji: String?
    var tint: SignColor
    var size: CGFloat = 44
    var iconColor: Color?

    var body: some View {
        RoundedRectangle(cornerRadius: size * 0.22, style: .continuous)
            .fill(tint.color)
            .frame(width: size, height: size)
            .overlay {
                if let emoji, !emoji.isEmpty {
                    Text(emoji)
                        .font(.system(size: size * 0.5))
                } else {
                    Image(systemName: systemIcon)
                        .font(.system(size: size * 0.44, weight: .bold))
                        .foregroundStyle(iconColor ?? tint.readableForeground)
                }
            }
            .accessibilityHidden(true)
    }
}

// MARK: - Menu row

/// One destination on the main menu, styled as a directory entry.
struct SignageRow: View {
    let title: String
    var subtitle: String?
    let systemIcon: String
    var emoji: String?
    let tint: SignColor

    @ScaledMetric(relativeTo: .headline) private var plateSize: CGFloat = 46
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        // Above the accessibility sizes a horizontal row cannot hold both the
        // plate and a readable title, so it stacks instead of truncating.
        let layout = typeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 10))
            : AnyLayout(HStackLayout(spacing: 14))

        layout {
            SignPlate(
                systemIcon: systemIcon,
                emoji: emoji,
                tint: tint,
                size: min(plateSize, 62)
            )

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.appHeadline)
                    .kerning(0.4)
                    .foregroundStyle(.primary)
                if let subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.appFootnote)
                        .foregroundStyle(SignagePalette.concrete.color)
                        .lineLimit(typeSize.isAccessibilitySize ? 4 : 2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .frame(minHeight: 60)
        .contentShape(Rectangle())
    }
}

// MARK: - Section header

/// A letterspaced caps header sitting on a short rule in the section's route
/// colour, the way a sign panel is titled.
struct PlatformHeader: View {
    let text: String
    var systemIcon: String?
    var tint: SignColor = SignagePalette.motorway
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Rectangle()
                .fill(tint.color)
                .frame(width: 30, height: 3)

            HStack(spacing: 6) {
                if let systemIcon {
                    Image(systemName: systemIcon)
                        .font(.appCaption)
                }
                Text(text.uppercased())
                    .font(.appCaption)
                    .kerning(1.2)
            }
            .foregroundStyle(SignagePalette.concrete.color)
        }
        .padding(.top, 8)
        .padding(.bottom, 2)
        .frame(maxWidth: .infinity, alignment: .leading)
        // Plain-list section headers float as the list scrolls. Give the
        // floating header an opaque surface so rows never show through it.
        .background(SignagePalette.surface(scheme))
        .textCase(nil)
        // Restore the un-shouted text for VoiceOver.
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(text)
        .accessibilityAddTraits(.isHeader)
    }
}

// MARK: - Press to talk

/// The large primary control. Deliberately the width of the screen and tall
/// enough to hit without looking, because it is pressed mid-conversation
/// while the wearer is also making eye contact.
struct PressToTalkButton: View {
    let title: String
    var systemIcon: String = "dot.radiowaves.left.and.right"
    var tint: SignColor = SignagePalette.motorway
    let action: () -> Void

    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: systemIcon)
                    .font(.system(size: 22, weight: .bold))
                Text(title.uppercased())
                    .font(.appTitle3)
                    .kerning(1.0)
                    .lineLimit(typeSize.isAccessibilitySize ? 3 : 1)
                    .minimumScaleFactor(0.7)
            }
            .foregroundStyle(tint.readableForeground)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(tint.color)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }
}

/// A compact control for the row along the bottom of a display view.
///
/// When it sits on a full-bleed badge, pass the badge's colour as `surface`.
/// The button then takes that colour's readable foreground as its fill and
/// the colour itself as its icon, so it stays legible on every badge in the
/// palette. A fixed tint cannot do that — a blue button on a blue badge
/// disappears, which is how this was found.
struct ControlButton: View {
    let systemIcon: String
    let label: String
    var tint: SignColor = SignagePalette.concrete
    var surface: SignColor?
    let action: () -> Void

    private var fill: Color {
        surface.map { $0.readableForeground } ?? tint.color
    }

    private var icon: Color {
        surface.map { $0.color } ?? tint.readableForeground
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: systemIcon)
                .font(.system(size: 19, weight: .bold))
                .foregroundStyle(icon)
                // A generous, uniform target. A near-miss on a display view
                // otherwise falls through to the tap-to-speak gesture behind
                // it, which re-speaks the badge at the worst moment.
                .frame(width: 56, height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(fill)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}

// MARK: - Surfaces

private struct SignageSurface: ViewModifier {
    var chevrons: Bool
    @Environment(\.colorScheme) private var scheme

    func body(content: Content) -> some View {
        content
            .scrollContentBackground(.hidden)
            .background {
                ZStack {
                    SignagePalette.surface(scheme)
                    if chevrons { ChevronBackground() }
                }
                .ignoresSafeArea()
            }
    }
}

/// Caps the reading column and centres it.
///
/// Without this the app is an iPhone layout stretched across an iPad: rows
/// span the full 820pt with the title pinned left and the trailing icon
/// marooned on the right, and the eye has to travel the whole width to
/// connect them. A station directory is a column, not a banner.
private struct SignageContentWidth: ViewModifier {
    /// Roughly the width the layout was designed at, plus a little.
    static let maxColumn: CGFloat = 640

    func body(content: Content) -> some View {
        GeometryReader { geometry in
            let margin = max(16, (geometry.size.width - Self.maxColumn) / 2)
            content.contentMargins(.horizontal, margin, for: .scrollContent)
        }
    }
}

extension View {
    /// The standard page background.
    func signageSurface(chevrons: Bool = true) -> some View {
        modifier(SignageSurface(chevrons: chevrons))
    }

    /// Constrains a scrolling page to a centred, readable column.
    /// Replaces a fixed horizontal content margin.
    func signageContentWidth() -> some View {
        modifier(SignageContentWidth())
    }

    /// Constrains a non-scrolling page to the same column.
    func signageColumn() -> some View {
        frame(maxWidth: SignageContentWidth.maxColumn)
            .frame(maxWidth: .infinity)
    }

    /// List row styling: full-bleed leading edge so the plate sits against
    /// the margin, and a plate-shaped row background instead of a separator.
    func signageRowStyle() -> some View {
        modifier(SignageRowStyle())
    }

    /// Section footer styling. Explicitly clears the row background, which a
    /// plain List otherwise gives footers, making explanatory text look like
    /// another tappable card.
    func signageFooter() -> some View {
        font(.appFootnote)
            .foregroundStyle(SignagePalette.concrete.color)
            .padding(.top, 6)
            .padding(.bottom, 4)
            .listRowInsets(EdgeInsets(top: 0, leading: 4, bottom: 8, trailing: 4))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
    }

    /// Makes a section title part of the scrolling content instead of using
    /// List's automatically pinned header supplementary view. Plain List
    /// headers otherwise float over rows and can inherit swipe artefacts.
    func signageHeaderRow() -> some View {
        listRowInsets(EdgeInsets(top: 2, leading: 0, bottom: 2, trailing: 0))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
    }
}

private struct SignageRowStyle: ViewModifier {
    @Environment(\.colorScheme) private var scheme
    @Environment(\.editMode) private var editMode

    func body(content: Content) -> some View {
        // A zero leading inset leaves no room for the red minus control that
        // appears in edit mode, which silently hides delete. The inset opens
        // up only while editing, so the plate still sits flush the rest of
        // the time.
        let leading: CGFloat = editMode?.wrappedValue.isEditing == true ? 12 : 0

        return content
            .listRowInsets(EdgeInsets(top: 4, leading: leading, bottom: 4, trailing: 16))
            .listRowSeparator(.hidden)
            .listRowBackground(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(SignagePalette.block(scheme))
                    .padding(.vertical, 3)
            )
    }
}

// MARK: - Chevron backdrop

/// The faint directional chevrons found on road-sign backing boards and
/// terminal wayfinding panels.
///
/// Drawn in a Canvas rather than as an image so it tiles at any size, and
/// removed entirely when the user has asked for increased contrast or
/// reduced transparency — decoration behind text is exactly what those
/// settings exist to switch off.
struct ChevronBackground: View {
    @Environment(\.colorScheme) private var scheme
    @Environment(\.colorSchemeContrast) private var contrast
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        if contrast == .increased || reduceTransparency {
            Color.clear
        } else {
            Canvas { context, size in
                let tile: CGFloat = 46
                let stroke = SignagePalette.concrete.color.opacity(scheme == .dark ? 0.06 : 0.045)
                let columns = Int(size.width / tile) + 2
                let rows = Int(size.height / tile) + 2

                for row in 0..<rows {
                    for column in 0..<columns {
                        // Half-drop repeat: every other row offsets by half a
                        // tile, which stops the chevrons reading as columns.
                        let x = CGFloat(column) * tile + (row.isMultiple(of: 2) ? 0 : tile / 2)
                        let y = CGFloat(row) * tile

                        var path = Path()
                        path.move(to: CGPoint(x: x + 10, y: y + 13))
                        path.addLine(to: CGPoint(x: x + 22, y: y + 23))
                        path.addLine(to: CGPoint(x: x + 10, y: y + 33))

                        context.stroke(
                            path,
                            with: .color(stroke),
                            style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round)
                        )
                    }
                }
            }
            .drawingGroup()
            .allowsHitTesting(false)
        }
    }
}

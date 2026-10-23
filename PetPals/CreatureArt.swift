import SwiftUI

// MARK: - Colors

/// The four fur colors a pet can have.
enum PetColor: String, CaseIterable {
    case berry = "Berry", sky = "Sky", mint = "Mint", sunny = "Sunny"

    private var rgb: (r: Double, g: Double, b: Double) {
        switch self {
        case .berry: return (0.90, 0.35, 0.43)
        case .sky:   return (0.31, 0.66, 0.91)
        case .mint:  return (0.30, 0.79, 0.63)
        case .sunny: return (1.00, 0.79, 0.24)
        }
    }

    var base: Color { Color(red: rgb.r, green: rgb.g, blue: rgb.b) }
    var light: Color { mixed(toward: 1, amount: 0.70) }
    var dark: Color { mixed(toward: 0, amount: 0.20) }

    private func mixed(toward target: Double, amount: Double) -> Color {
        Color(red: rgb.r + (target - rgb.r) * amount,
              green: rgb.g + (target - rgb.g) * amount,
              blue: rgb.b + (target - rgb.b) * amount)
    }

    static func named(_ name: String) -> PetColor { PetColor(rawValue: name) ?? .sky }
}

// MARK: - Species

enum EarStyle { case pointy, long, round, horn, antenna, none }
enum ExtraStyle { case sprout, wings, bigTail, spots, none }

/// An original species. Each one is a variation on the same body plan.
struct SpeciesInfo: Identifiable {
    let name: String
    let ears: EarStyle
    let extra: ExtraStyle
    let rx: CGFloat
    let ry: CGFloat
    var id: String { name }

    static let all: [SpeciesInfo] = [
        SpeciesInfo(name: "Glimmoo",  ears: .pointy,  extra: .sprout,  rx: 66, ry: 58),
        SpeciesInfo(name: "Bunnoo",   ears: .long,    extra: .none,    rx: 58, ry: 62),
        SpeciesInfo(name: "Fluffet",  ears: .round,   extra: .bigTail, rx: 64, ry: 58),
        SpeciesInfo(name: "Snorbit",  ears: .horn,    extra: .spots,   rx: 68, ry: 56),
        SpeciesInfo(name: "Wingle",   ears: .antenna, extra: .wings,   rx: 62, ry: 58),
        SpeciesInfo(name: "Toadle",   ears: .none,    extra: .spots,   rx: 74, ry: 50),
        SpeciesInfo(name: "Tuftail",  ears: .pointy,  extra: .bigTail, rx: 62, ry: 60),
        SpeciesInfo(name: "Pebbo",    ears: .round,   extra: .spots,   rx: 72, ry: 54),
        SpeciesInfo(name: "Squeakle", ears: .round,   extra: .none,    rx: 56, ry: 60),
        SpeciesInfo(name: "Dribble",  ears: .antenna, extra: .sprout,  rx: 64, ry: 56),
        SpeciesInfo(name: "Mooble",   ears: .horn,    extra: .bigTail, rx: 66, ry: 58),
        SpeciesInfo(name: "Starbit",  ears: .pointy,  extra: .wings,   rx: 60, ry: 60)
    ]

    static func info(for name: String) -> SpeciesInfo {
        all.first { $0.name == name } ?? all[0]
    }
}

// MARK: - View

/// Draws a pet in code, so the project needs no image assets for its creatures.
struct CreatureView: View {
    let species: String
    let color: String

    var body: some View {
        Canvas { context, size in
            let info = SpeciesInfo.info(for: species)
            let palette = PetColor.named(color)
            let scale = min(size.width, size.height) / 200
            var g = context
            g.translateBy(x: (size.width - 200 * scale) / 2, y: (size.height - 200 * scale) / 2)
            g.scaleBy(x: scale, y: scale)
            CreatureArt.draw(&g, info: info, palette: palette)
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityElement()
        .accessibilityLabel("\(color) \(species)")
    }
}

// MARK: - Drawing

enum CreatureArt {
    private static let ink = Color(red: 0.12, green: 0.16, blue: 0.27)
    private static let pink = Color(red: 1.00, green: 0.70, blue: 0.78)
    private static let leaf = Color(red: 0.48, green: 0.85, blue: 0.56)
    private static let horn = Color(red: 1.00, green: 0.85, blue: 0.35)

    private static func shape(_ g: inout GraphicsContext, _ path: Path, fill: Color, line: CGFloat = 4) {
        g.fill(path, with: .color(fill))
        g.stroke(path, with: .color(ink),
                 style: StrokeStyle(lineWidth: line, lineCap: .round, lineJoin: .round))
    }

    private static func ellipse(_ cx: CGFloat, _ cy: CGFloat, _ rx: CGFloat, _ ry: CGFloat,
                                rotation: CGFloat = 0) -> Path {
        let base = Path(ellipseIn: CGRect(x: -rx, y: -ry, width: rx * 2, height: ry * 2))
        let transform = CGAffineTransform(rotationAngle: rotation)
            .concatenating(CGAffineTransform(translationX: cx, y: cy))
        return base.applying(transform)
    }

    private static func polygon(_ points: [CGPoint]) -> Path {
        var path = Path()
        path.addLines(points)
        path.closeSubpath()
        return path
    }

    static func draw(_ g: inout GraphicsContext, info: SpeciesInfo, palette: PetColor) {
        let cx: CGFloat = 100
        let cy: CGFloat = 118
        let rx = info.rx
        let ry = info.ry
        let top = cy - ry
        let base = palette.base

        // Ground shadow
        g.fill(ellipse(cx, 184, 58, 8), with: .color(.black.opacity(0.12)))

        // Tail
        let bigTail = info.extra == .bigTail
        shape(&g, ellipse(cx + rx - 2, cy + 18, bigTail ? 30 : 16, bigTail ? 16 : 9, rotation: -0.7), fill: base)

        // Wings (behind the body)
        if info.extra == .wings {
            shape(&g, ellipse(cx - rx - 6, cy - 8, 34, 17, rotation: -0.6), fill: palette.light)
            shape(&g, ellipse(cx + rx + 6, cy - 8, 34, 17, rotation: 0.6), fill: palette.light)
        }

        // Ears, horn or antennae (behind the body)
        switch info.ears {
        case .pointy:
            shape(&g, polygon([CGPoint(x: cx - rx * 0.78, y: top + ry * 0.36),
                               CGPoint(x: cx - rx * 0.90, y: top - 34),
                               CGPoint(x: cx - rx * 0.15, y: top + 4)]), fill: base)
            shape(&g, polygon([CGPoint(x: cx + rx * 0.78, y: top + ry * 0.36),
                               CGPoint(x: cx + rx * 0.90, y: top - 34),
                               CGPoint(x: cx + rx * 0.15, y: top + 4)]), fill: base)
        case .long:
            shape(&g, Path(roundedRect: CGRect(x: cx - 36, y: top - 50, width: 26, height: 80),
                           cornerSize: CGSize(width: 13, height: 13)), fill: base)
            shape(&g, Path(roundedRect: CGRect(x: cx + 10, y: top - 50, width: 26, height: 80),
                           cornerSize: CGSize(width: 13, height: 13)), fill: base)
            g.fill(Path(roundedRect: CGRect(x: cx - 30, y: top - 38, width: 14, height: 54),
                        cornerSize: CGSize(width: 7, height: 7)), with: .color(pink))
            g.fill(Path(roundedRect: CGRect(x: cx + 16, y: top - 38, width: 14, height: 54),
                        cornerSize: CGSize(width: 7, height: 7)), with: .color(pink))
        case .round:
            shape(&g, ellipse(cx - rx * 0.72, top + 14, 17, 17), fill: base)
            shape(&g, ellipse(cx + rx * 0.72, top + 14, 17, 17), fill: base)
            g.fill(ellipse(cx - rx * 0.72, top + 14, 8, 8), with: .color(pink))
            g.fill(ellipse(cx + rx * 0.72, top + 14, 8, 8), with: .color(pink))
        case .horn:
            shape(&g, polygon([CGPoint(x: cx - 14, y: top + 8),
                               CGPoint(x: cx + 2, y: top - 40),
                               CGPoint(x: cx + 16, y: top + 8)]), fill: horn)
        case .antenna:
            for side in [CGFloat(-1), CGFloat(1)] {
                var stem = Path()
                stem.move(to: CGPoint(x: cx + side * 18, y: top + 6))
                stem.addQuadCurve(to: CGPoint(x: cx + side * 34, y: top - 32),
                                  control: CGPoint(x: cx + side * 16, y: top - 22))
                g.stroke(stem, with: .color(ink),
                         style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                shape(&g, ellipse(cx + side * 34, top - 34, 7, 7), fill: horn)
            }
        case .none:
            break
        }

        // Feet and body
        shape(&g, ellipse(cx - 32, 172, 20, 11), fill: base)
        shape(&g, ellipse(cx + 32, 172, 20, 11), fill: base)
        shape(&g, ellipse(cx, cy, rx, ry), fill: base)

        // Spots
        if info.extra == .spots {
            g.fill(ellipse(cx - rx * 0.45, cy - ry * 0.45, 9, 7), with: .color(palette.dark))
            g.fill(ellipse(cx + rx * 0.50, cy - ry * 0.35, 7, 6), with: .color(palette.dark))
            g.fill(ellipse(cx + rx * 0.55, cy + ry * 0.20, 8, 6), with: .color(palette.dark))
        }

        // Belly
        g.fill(ellipse(cx, cy + ry * 0.30, rx * 0.58, ry * 0.50), with: .color(palette.light))

        // Head sprout
        if info.extra == .sprout {
            var sprout = Path()
            sprout.move(to: CGPoint(x: cx, y: top + 2))
            sprout.addCurve(to: CGPoint(x: cx + 8, y: top - 28),
                            control1: CGPoint(x: cx - 10, y: top - 12),
                            control2: CGPoint(x: cx - 4, y: top - 26))
            sprout.addCurve(to: CGPoint(x: cx, y: top + 2),
                            control1: CGPoint(x: cx + 12, y: top - 14),
                            control2: CGPoint(x: cx + 8, y: top - 6))
            shape(&g, sprout, fill: leaf, line: 3.5)
        }

        // Face
        let eyeY = cy - 12
        g.fill(ellipse(cx - 24, eyeY, 9, 9), with: .color(ink))
        g.fill(ellipse(cx + 24, eyeY, 9, 9), with: .color(ink))
        g.fill(ellipse(cx - 21, eyeY - 3, 3, 3), with: .color(.white))
        g.fill(ellipse(cx + 27, eyeY - 3, 3, 3), with: .color(.white))
        g.fill(ellipse(cx - 42, cy + 8, 9, 6), with: .color(pink))
        g.fill(ellipse(cx + 42, cy + 8, 9, 6), with: .color(pink))
        var smile = Path()
        smile.move(to: CGPoint(x: cx - 10, y: cy + 8))
        smile.addQuadCurve(to: CGPoint(x: cx + 10, y: cy + 8), control: CGPoint(x: cx, y: cy + 22))
        g.stroke(smile, with: .color(ink),
                 style: StrokeStyle(lineWidth: 3.5, lineCap: .round, lineJoin: .round))
    }
}

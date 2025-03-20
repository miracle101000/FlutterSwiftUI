import SwiftUI

// MARK: - TextSpanView

/// A view that displays text with customizable styling and an optional tap gesture.
/// It can also render the text with a linear gradient fill if gradient colors are provided.
///
/// Example usage:
/// ```swift
/// TextSpanView(
///     text: "Hello",
///     textAlign: .center,
///     textScaler: 1.5,
///     fontSize: 20,
///     fontWeight: .bold,
///     lineSpacing: 4,
///     letterSpacing: 0.5,
///     maxLines: 2,
///     color: .blue,
///     gradient: [Color.red, Color.yellow, Color.blue],
///     gradientAngle: 45,
///     onTap: { print("Text tapped!") }
/// )
/// ```
///
/// - Parameters:
///   - text: The text to display.
///   - textAlign: The text alignment. Defaults to `.leading`.
///   - textScaler: A multiplier for scaling the font size. Defaults to 1.
///   - fontSize: The font size in points. If not provided, a default system size is used.
///   - fontWeight: The weight of the font. Defaults to nil.
///   - lineSpacing: The spacing between lines of text. Defaults to nil.
///   - letterSpacing: The spacing between letters. Defaults to nil.
///   - maxLines: The maximum number of lines to display. (Note: Truncation is handled by SwiftUI’s lineLimit.)
///   - color: The text color. Defaults to `.black`.
///   - gradient: An optional array of colors for a linear gradient fill.
///   - gradientAngle: The angle (in degrees) for the gradient direction. Defaults to 0.
///   - onTap: An optional closure executed when the text is tapped.
public struct TextSpanView: View {
    let text: String?
    let textAlign: TextAlignment
    let textScaler: CGFloat
    let fontSize: CGFloat?
    let fontWeight: Font.Weight?
    let lineSpacing: CGFloat?
    let letterSpacing: CGFloat?
    let maxLines: Int?
    let color: Color
    let gradient: [Color]?
    let gradientAngle: Double
    let onTap: (() -> Void)?

    public init(
        text: String? = nil,
        textAlign: TextAlignment = .leading,
        textScaler: CGFloat = 1,
        fontSize: CGFloat? = nil,
        fontWeight: Font.Weight? = nil,
        lineSpacing: CGFloat? = nil,
        letterSpacing: CGFloat? = nil,
        maxLines: Int? = nil,
        color: Color = .black,
        gradient: [Color]? = nil,
        gradientAngle: Double = 0,
        onTap: (() -> Void)? = nil
    ) {
        self.text = text
        self.textAlign = textAlign
        self.textScaler = textScaler
        self.fontSize = fontSize
        self.fontWeight = fontWeight
        self.lineSpacing = lineSpacing
        self.letterSpacing = letterSpacing
        self.maxLines = maxLines
        self.color = color
        self.gradient = gradient
        self.gradientAngle = gradientAngle
        self.onTap = onTap
    }
    
    public var body: some View {
        Group {
            if let text = text {
                // If a gradient is provided, overlay the text with a gradient mask.
                if let gradient = gradient {
                    Text(text)
                        .font(.system(size: (fontSize ?? 17) * textScaler))
                        .fontWeight(fontWeight)
                        .lineSpacing(lineSpacing ?? 0)
                        .kerning(letterSpacing ?? 0)
                        .multilineTextAlignment(textAlign)
                        .lineLimit(maxLines)
                        .foregroundColor(.clear)
                        .overlay(
                            LinearGradient(
                                gradient: Gradient(colors: gradient),
                                startPoint: gradientStartPoint(for: gradientAngle),
                                endPoint: gradientEndPoint(for: gradientAngle)
                            )
                        )
                        .onTapGesture { onTap?() }
                } else {
                    Text(text)
                        .font(.system(size: (fontSize ?? 17) * textScaler))
                        .fontWeight(fontWeight)
                        .lineSpacing(lineSpacing ?? 0)
                        .kerning(letterSpacing ?? 0)
                        .multilineTextAlignment(textAlign)
                        .lineLimit(maxLines)
                        .foregroundColor(color)
                        .onTapGesture { onTap?() }
                }
            } else {
                EmptyView()
            }
        }
    }
    
    /// Computes the gradient start point based on the angle.
    private func gradientStartPoint(for angle: Double) -> UnitPoint {
        let radians = angle * .pi / 180
        // For a simple approximation, map 0 degrees to .leading.
        return UnitPoint(x: 0.5 - 0.5 * cos(radians), y: 0.5 - 0.5 * sin(radians))
    }
    
    /// Computes the gradient end point based on the angle.
    private func gradientEndPoint(for angle: Double) -> UnitPoint {
        let radians = angle * .pi / 180
        return UnitPoint(x: 0.5 + 0.5 * cos(radians), y: 0.5 + 0.5 * sin(radians))
    }
}

// MARK: - WidgetSpanView

/// A view that wraps its content in an inline container, similar to an HTML span element.
/// Use this to embed inline widgets (e.g., images, buttons) within text.
///
/// Example usage:
/// ```swift
/// WidgetSpanView {
///     Image(systemName: "star.fill")
///         .foregroundColor(.yellow)
/// }
/// ```
///
/// - Parameter content: A view builder that creates the inline content.
struct WidgetSpanView<Content: View>: View {
    let content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        // An HStack with zero spacing simulates an inline-block element.
        HStack(spacing: 0) {
            content()
        }
    }
}

// MARK: - RichTextView

/// A container view that arranges its inline children (such as TextSpanView and WidgetSpanView)
/// in a single line. This mimics rich text rendering, similar to Flutter's RichText.
///
/// Example usage:
/// ```swift
/// RichTextView {
///     TextSpanView(
///         text: "Hello",
///         textAlign: .center,
///         textScaler: 1.5,
///         fontSize: 20,
///         fontWeight: .bold,
///         lineSpacing: 4,
///         letterSpacing: 0.5,
///         maxLines: 2,
///         color: .blue,
///         gradient: [Color.red, Color.yellow, Color.blue],
///         gradientAngle: 45,
///         onTap: { print("Hello tapped!") }
///     )
///     TextSpanView(
///         text: " world!",
///         color: .red,
///         onTap: { print("World tapped!") }
///     )
/// }
/// ```
///
/// - Parameter content: A view builder that creates the inline elements.
struct RichTextView<Content: View>: View {
    let content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        // Use an HStack with zero spacing to simulate inline rendering.
        HStack(spacing: 0) {
            content()
        }
    }
}

// MARK: - Previews

struct RichTextView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Example with gradient text and tap gestures.
            RichTextView {
                TextSpanView(
                    text: "Hello",
                    textAlign: .center,
                    textScaler: 1.5,
                    fontSize: 20,
                    fontWeight: .bold,
                    lineSpacing: 4,
                    letterSpacing: 0.5,
                    maxLines: 2,
                    color: .blue,
                    gradient: [Color.red, Color.yellow, Color.blue],
                    gradientAngle: 45,
                    onTap: { print("Hello tapped!") }
                )
                TextSpanView(
                    text: " world!",
                    color: .red,
                    onTap: { print("World tapped!") }
                )
            }
            .padding()
            
            // Example using WidgetSpanView inline with text.
            RichTextView {
                TextSpanView(text: "Rate this: ", fontSize: 16)
                WidgetSpanView {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                }
                TextSpanView(text: " out of 5", fontSize: 16)
            }
            .padding()
        }
        .previewLayout(.sizeThatFits)
    }
}

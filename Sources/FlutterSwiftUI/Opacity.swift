import SwiftUI

/// A view that applies an opacity effect to its child content.
/// This view ensures that the provided opacity value is clamped between 0 (fully transparent) and 1 (fully opaque).
///
/// Example usage:
/// ```swift
/// Opacity(opacity: 0.5) {
///     Rectangle()
///         .fill(Color.red)
///         .frame(width: 100, height: 100)
/// }
/// ```
///
/// - Parameters:
///   - opacity: The opacity value to apply to the content. Valid values are between 0 and 1.
///   - content: A view builder that constructs the view's content.
public struct Opacity<Content: View>: View {
    private let opacity: Double
    private let content: Content

    /// Initializes a new `OpacityView` instance.
    ///
    /// - Parameters:
    ///   - opacity: The opacity value to apply to the content. Values are clamped between 0 and 1.
    ///   - content: A view builder that constructs the view's content.
    public init(opacity: Double, @ViewBuilder content: () -> Content) {
        // Clamp the opacity between 0 and 1.
        self.opacity = min(max(opacity, 0), 1)
        self.content = content()
    }

    public var body: some View {
        content
            .opacity(opacity)
    }
}

/// A preview provider for the `OpacityView`.
struct Opacity_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // 50% opacity view (semi-transparent)
            Opacity(opacity: 0.5) {
                Rectangle()
                    .fill(Color.red)
                    .frame(width: 100, height: 100)
            }

            // Fully opaque view
            Opacity(opacity: 1) {
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: 100, height: 100)
            }

            // Fully transparent view
            Opacity(opacity: 0) {
                Rectangle()
                    .fill(Color.green)
                    .frame(width: 100, height: 100)
            }
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}

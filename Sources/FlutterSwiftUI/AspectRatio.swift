import SwiftUI

/// A view that maintains a consistent aspect ratio for its content.
///
/// This component ensures that its child view retains a specific width-to-height ratio,
/// dynamically adjusting the height based on its available width.
///
/// - Parameters:
///   - aspectRatio: The desired width-to-height ratio (e.g., `16/9` for widescreen).
///   - content: The view that should maintain the given aspect ratio.
///
/// Example usage:
/// ```swift
/// AspectRatio(aspectRatio: 16/9) {
///     Rectangle()
///         .fill(Color.red)
///         .overlay(Text("16:9 Aspect Ratio").foregroundColor(.white))
/// }
/// ```
public struct AspectRatio<Content: View>: View {
    let aspectRatio: CGFloat
    let content: Content

    /// Initializes an `AspectRatio` component with the given aspect ratio and child content.
    /// - Parameters:
    ///   - aspectRatio: The width-to-height ratio.
    ///   - content: The view that should maintain the specified aspect ratio.
    public init(aspectRatio: CGFloat, @ViewBuilder content: () -> Content) {
        self.aspectRatio = aspectRatio
        self.content = content()
    }

    public var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = width / aspectRatio
            content
                .frame(width: width, height: height)
                .clipped()
        }
        .frame(maxWidth: .infinity) // Ensures full width
    }
}

/// Example usage of `AspectRatio`
struct AspectRatio_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            AspectRatio(aspectRatio: 16/9) {
                Rectangle()
                    .fill(Color.blue)
                    .overlay(Text("16:9 Aspect Ratio").foregroundColor(.white))
            }
            .padding()

            AspectRatio(aspectRatio: 1) {
                Circle()
                    .fill(Color.green)
                    .overlay(Text("1:1 Square").foregroundColor(.white))
            }
            .padding()
        }
    }
}

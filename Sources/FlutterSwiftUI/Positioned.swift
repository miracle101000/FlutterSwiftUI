import SwiftUI

/// A view that positions its child relative to its parent’s bounds, similar to Flutter’s Positioned widget.
/// Place this view inside a ZStack (or similar container) with a fixed frame to achieve absolute positioning.
///
/// Example usage:
/// ```swift
/// ZStack {
///     Color.gray.opacity(0.2)
///     Positioned(top: 10, left: 10) {
///         Rectangle()
///             .fill(Color.blue)
///             .frame(width: 100, height: 100)
///     }
/// }
/// .frame(width: 300, height: 300)
///
/// ZStack {
///     Color.gray.opacity(0.2)
///     Positioned(bottom: 20, right: 20) {
///         Rectangle()
///             .fill(Color.green)
///             .frame(width: 100, height: 100)
///     }
/// }
/// .frame(width: 300, height: 300)
/// ```
///
/// - Parameters:
///   - top: The offset from the top edge (in points).
///   - left: The offset from the left edge (in points).
///   - right: The offset from the right edge (in points).
///   - bottom: The offset from the bottom edge (in points).
///   - content: A view builder that constructs the content to be positioned.
public struct Positioned<Content: View>: View {
    let top: CGFloat?
    let left: CGFloat?
    let right: CGFloat?
    let bottom: CGFloat?
    let content: Content

    /// Initializes a new PositionedView.
    ///
    /// - Parameters:
    ///   - top: The offset from the top edge (optional).
    ///   - left: The offset from the left edge (optional).
    ///   - right: The offset from the right edge (optional).
    ///   - bottom: The offset from the bottom edge (optional).
    ///   - content: A view builder that creates the content to be positioned.
    public init(top: CGFloat? = nil,
         left: CGFloat? = nil,
         right: CGFloat? = nil,
         bottom: CGFloat? = nil,
         @ViewBuilder content: () -> Content) {
        self.top = top
        self.left = left
        self.right = right
        self.bottom = bottom
        self.content = content()
    }

    public var body: some View {
        GeometryReader { geometry in
            // Determine horizontal alignment.
            let horizontalAlignment: HorizontalAlignment = {
                if left != nil { return .leading }
                if right != nil { return .trailing }
                return .center
            }()
            // Determine vertical alignment.
            let verticalAlignment: VerticalAlignment = {
                if top != nil { return .top }
                if bottom != nil { return .bottom }
                return .center
            }()
            let alignment = Alignment(horizontal: horizontalAlignment, vertical: verticalAlignment)
            
            ZStack(alignment: alignment) {
                // An invisible background that fills the container.
                Color.clear
                // The content is offset by padding values if provided.
                content
                    .padding(.top, top ?? 0)
                    .padding(.leading, left ?? 0)
                    .padding(.bottom, bottom ?? 0)
                    .padding(.trailing, right ?? 0)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

struct Positioned_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 30) {
            // Top-left positioned content.
            ZStack {
                Color.gray.opacity(0.2)
                Positioned(top: 10, left: 10) {
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: 100, height: 100)
                }
            }
            .frame(width: 300, height: 300)
            
            // Bottom-right positioned content.
            ZStack {
                Color.gray.opacity(0.2)
                Positioned(right: 20, bottom: 20) {
                    Rectangle()
                        .fill(Color.green)
                        .frame(width: 100, height: 100)
                }
            }
            .frame(width: 300, height: 300)
        }
        .previewLayout(.sizeThatFits)
    }
}

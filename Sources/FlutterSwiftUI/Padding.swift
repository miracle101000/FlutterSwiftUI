import SwiftUI

/// A view that applies padding around its child content.
///
/// You can specify padding for individual edges (top, right, bottom, left)
/// or provide a uniform padding for all sides. If an individual edge is not
/// specified, the uniform padding (if provided) is used for that edge.
///
/// Example usage:
/// ```swift
/// // Uniform padding of 20 points on all sides
/// Padding(uniformPadding: 20) {
///     Text("This text has 20pt of padding around it.")
///         .background(Color.blue)
/// }
///
/// // Custom padding: 10pt top and bottom, 20pt left and right
/// Padding(paddingTop: 10, paddingRight: 20, paddingBottom: 10, paddingLeft: 20) {
///     Text("This text has custom padding.")
///         .background(Color.green)
/// }
/// ```
///
/// - Parameters:
///   - paddingTop: The padding for the top edge (in points).
///   - paddingRight: The padding for the right edge (in points).
///   - paddingBottom: The padding for the bottom edge (in points).
///   - paddingLeft: The padding for the left edge (in points).
///   - uniformPadding: A uniform padding value (in points) applied to all edges
///                     if individual paddings are not specified.
///   - content: A view builder that creates the content view to which padding is applied.
public struct Padding<Content: View>: View {
    let paddingTop: CGFloat?
    let paddingRight: CGFloat?
    let paddingBottom: CGFloat?
    let paddingLeft: CGFloat?
    let uniformPadding: CGFloat?
    let content: Content
    
    /// Creates a new `PaddingView`.
    ///
    /// - Parameters:
    ///   - paddingTop: The padding for the top edge (optional).
    ///   - paddingRight: The padding for the right edge (optional).
    ///   - paddingBottom: The padding for the bottom edge (optional).
    ///   - paddingLeft: The padding for the left edge (optional).
    ///   - uniformPadding: A uniform padding value for all edges (optional).
    ///   - content: A view builder that constructs the view's content.
    public init(
        paddingTop: CGFloat? = nil,
        paddingRight: CGFloat? = nil,
        paddingBottom: CGFloat? = nil,
        paddingLeft: CGFloat? = nil,
        uniformPadding: CGFloat? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.paddingTop = paddingTop
        self.paddingRight = paddingRight
        self.paddingBottom = paddingBottom
        self.paddingLeft = paddingLeft
        self.uniformPadding = uniformPadding
        self.content = content()
    }
    
    public var body: some View {
        // Compute each edge's padding: use individual value if provided, otherwise fall back to uniformPadding, else 0.
        let top = paddingTop ?? uniformPadding ?? 0
        let right = paddingRight ?? uniformPadding ?? 0
        let bottom = paddingBottom ?? uniformPadding ?? 0
        let left = paddingLeft ?? uniformPadding ?? 0
        
        return content
            .padding(EdgeInsets(top: top, leading: left, bottom: bottom, trailing: right))
    }
}

/// Example usage and preview.
struct Padding_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Uniform padding of 20 points
            Padding(uniformPadding: 20) {
                Text("Uniform Padding 20")
                    .background(Color.blue.opacity(0.2))
            }
            // Custom padding: 10pt top/bottom and 20pt left/right
            Padding(paddingTop: 10, paddingRight: 20, paddingBottom: 10, paddingLeft: 20) {
                Text("Top & Bottom 10, Left & Right 20")
                    .background(Color.green.opacity(0.2))
            }
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}

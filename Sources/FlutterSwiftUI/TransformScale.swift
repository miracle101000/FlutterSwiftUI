import SwiftUI

/// A view that scales its child content by a specified factor, similar to Flutter's Transform.scale.
/// The scaling is applied using SwiftUI's `scaleEffect` modifier with a customizable anchor point.
///
/// Example usage:
/// ```swift
/// TransformScaleView(scale: 1.5, origin: .center) {
///     Rectangle()
///         .fill(Color.red)
///         .frame(width: 50, height: 50)
/// }
/// .frame(width: 100, height: 100)
/// ```
///
/// - Parameters:
///   - scale: The scaling factor (e.g., 1.5 for 150% scale).
///   - origin: The pivot point for the scaling transformation, specified as a UnitPoint.
///             Defaults to `.center`.
///   - content: A view builder that provides the child content to be scaled.
public struct TransformScale<Content: View>: View {
    let scale: CGFloat
    let origin: UnitPoint
    let content: Content

    public init(scale: CGFloat, origin: UnitPoint = .center, @ViewBuilder content: () -> Content) {
        self.scale = scale
        self.origin = origin
        self.content = content()
    }
    
    public var body: some View {
        content
            .scaleEffect(scale, anchor: origin)
    }
}

struct TransformScale_Previews: PreviewProvider {
    static var previews: some View {
        TransformScale(scale: 1.5, origin: .center) {
            Rectangle()
                .fill(Color.red)
                .frame(width: 50, height: 50)
        }
        .frame(width: 100, height: 100)
        .previewLayout(.sizeThatFits)
        .padding()
    }
}

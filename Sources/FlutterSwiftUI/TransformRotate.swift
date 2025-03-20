import SwiftUI

/// A view that rotates its child content by a specified angle, similar to Flutter's `Transform.rotate`.
///
/// The rotation is applied using SwiftUI's `rotationEffect` modifier, and you can specify the pivot point (anchor)
/// for the rotation using a `UnitPoint`. By default, the anchor is `.center`.
///
/// Example usage:
/// ```swift
/// TransformRotateView(angle: 45, origin: .center) {
///     Rectangle()
///         .fill(Color.green)
///         .frame(width: 100, height: 100)
/// }
/// ```
///
/// - Parameters:
///   - angle: The rotation angle in degrees (e.g., 45 for a 45-degree rotation).
///   - origin: The pivot point (anchor) for the rotation. Defaults to `.center`.
///   - content: A view builder that provides the content to be rotated.
public struct TransformRotate<Content: View>: View {
    let angle: Double
    let origin: UnitPoint
    let content: Content

    public init(angle: Double, origin: UnitPoint = .center, @ViewBuilder content: () -> Content) {
        self.angle = angle
        self.origin = origin
        self.content = content()
    }
    
    public var body: some View {
        content
            .rotationEffect(Angle(degrees: angle), anchor: origin)
    }
}

struct TransformRotate_Previews: PreviewProvider {
    static var previews: some View {
        TransformRotate(angle: 45, origin: .center) {
            Rectangle()
                .fill(Color.green)
                .frame(width: 100, height: 100)
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}

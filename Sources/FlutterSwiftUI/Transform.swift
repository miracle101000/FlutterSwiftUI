import SwiftUI

/// A view that applies a custom transform to its child content, similar to a CSS transform.
/// It allows you to specify a transform (as a CGAffineTransform) and a transform origin (pivot point)
/// where the transform should be applied.
///
/// The transform is applied using the following steps:
/// 1. Compute the offset between the view's center and the desired anchor point.
/// 2. Translate the content so that the anchor point becomes the origin.
/// 3. Apply the transform.
/// 4. Translate the content back to its original position.
///
/// Example usage:
/// ```swift
/// TransformView(
///     transform: CGAffineTransform(rotationAngle: .pi/4).scaledBy(x: 1.5, y: 1.5),
///     origin: .center
/// ) {
///     Rectangle()
///         .fill(Color.blue)
///         .frame(width: 100, height: 100)
/// }
/// ```
///
/// - Parameters:
///   - transform: A CGAffineTransform representing the transformation to apply (e.g., rotation, scaling).
///   - origin: The pivot point for the transformation as a UnitPoint (default is .center).
///   - content: A view builder that provides the child content to transform.
public struct Transform<Content: View>: View {
    let transform: CGAffineTransform
    let origin: UnitPoint
    let content: Content
    
    public init(
        transform: CGAffineTransform,
        origin: UnitPoint = .center,
        @ViewBuilder content: () -> Content
    ) {
        self.transform = transform
        self.origin = origin
        self.content = content()
    }
    
    public var body: some View {
        GeometryReader { geometry in
            // Determine the size of the content.
            let size = geometry.size
            // The center of the view.
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            // The actual point corresponding to the specified origin.
            let anchorPoint = CGPoint(x: size.width * origin.x, y: size.height * origin.y)
            // Compute the offset from the view's center to the desired anchor point.
            let delta = CGPoint(x: anchorPoint.x - center.x, y: anchorPoint.y - center.y)
            // Create translation transforms.
            let translationToAnchor = CGAffineTransform(translationX: -delta.x, y: -delta.y)
            let translationBack = CGAffineTransform(translationX: delta.x, y: delta.y)
            // Combine the transforms: first translate so that the anchor is at the origin, apply the transform, then translate back.
            let fullTransform = translationBack.concatenating(transform).concatenating(translationToAnchor)
            
            ZStack {
                content
            }
            .frame(width: size.width, height: size.height)
            .transformEffect(fullTransform)
        }
        // Use the same frame as the content.
        .fixedSize(horizontal: false, vertical: false)
    }
}

struct Transform_Previews: PreviewProvider {
    static var previews: some View {
        Transform(
            transform: CGAffineTransform(rotationAngle: .pi/4).scaledBy(x: 1.5, y: 1.5),
            origin: .center
        ) {
            Rectangle()
                .fill(Color.blue)
                .frame(width: 100, height: 100)
        }
        .frame(width: 150, height: 150)
        .border(Color.gray)
        .previewLayout(.sizeThatFits)
    }
}

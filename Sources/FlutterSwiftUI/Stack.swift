import SwiftUI

/// A view that positions its children on top of each other, similar to a React Stack component.
/// This view wraps its content in a ZStack with a "relative" positioning context.
///
/// Example usage:
/// ```swift
/// StackView {
///     // Assume PositionedView and PositionedFillView are implemented similarly to prior examples.
///     PositionedView(top: 20, left: 10) {
///         Rectangle()
///             .fill(Color.red)
///             .frame(width: 50, height: 50)
///     }
///     PositionedFillView {
///         Color.green
///             .opacity(0.5)
///     }
/// }
/// .frame(width: 300, height: 300)
/// .background(Color.blue.opacity(0.3))
/// ```
///
/// Note: Use additional modifiers (like .frame, .background, etc.) on the StackView to style it.
public struct StackView<Content: View>: View {
    let content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        ZStack {
            content
        }
    }
}

struct StackView_Previews: PreviewProvider {
    static var previews: some View {
        StackView {
            // Example using custom PositionedView and PositionedFillView (assumed implemented elsewhere)
            // Here we simply overlay two rectangles for demonstration.
            Rectangle()
                .fill(Color.red)
                .frame(width: 50, height: 50)
                .offset(x: 10, y: 20)
            Color.green
                .opacity(0.5)
        }
        .frame(width: 300, height: 300)
        .background(Color.blue.opacity(0.3))
        .previewLayout(.sizeThatFits)
    }
}

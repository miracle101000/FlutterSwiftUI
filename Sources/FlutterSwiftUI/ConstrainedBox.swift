import SwiftUI

/**
 A view that imposes layout constraints on its child.
 
 The `ConstrainedBox` component allows you to specify maximum and minimum width/height constraints for its child,
 similar to Flutter's `ConstrainedBox` widget.
 
 ## Example Usage:
 ```swift
 ConstrainedBox(
     maxWidth: 200, minHeight: 100
 ) {
     Text("Hello, World!")
         .padding()
         .background(Color.blue)
         .foregroundColor(.white)
 }
 ```
 
 ## Properties:
 - `maxWidth`: The maximum width constraint for the child view (optional).
 - `maxHeight`: The maximum height constraint for the child view (optional).
 - `minWidth`: The minimum width constraint for the child view (optional).
 - `minHeight`: The minimum height constraint for the child view (optional).
 - `content`: The child view to be constrained.
 
 ## Notes:
 - This component uses `frame` modifiers to enforce constraints on the child.
 - If a constraint is not provided, the default behavior is to allow the content's intrinsic size.
 */
public struct ConstrainedBox<Content: View>: View {
    let maxWidth: CGFloat?
    let maxHeight: CGFloat?
    let minWidth: CGFloat?
    let minHeight: CGFloat?
    let content: Content
    
    public init(
        maxWidth: CGFloat? = nil,
        maxHeight: CGFloat? = nil,
        minWidth: CGFloat? = nil,
        minHeight: CGFloat? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.maxWidth = maxWidth
        self.maxHeight = maxHeight
        self.minWidth = minWidth
        self.minHeight = minHeight
        self.content = content()
    }
    
    public var body: some View {
        content
            .frame(
                minWidth: minWidth, maxWidth: maxWidth,
                minHeight: minHeight, maxHeight: maxHeight
            )
    }
}

// MARK: - Preview
struct ConstrainedBox_Previews: PreviewProvider {
    static var previews: some View {
        ConstrainedBox(
            maxWidth: 200, minHeight: 100
        ) {
            Text("Hello, World!")
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
        }
        .border(Color.gray)
    }
}

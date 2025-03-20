import SwiftUI

/// A view that positions its child to fill the entire parent container,
/// similar to Flutter's `Positioned.fill`.
///
/// Example usage:
/// ```swift
/// ZStack {
///     Color.gray.opacity(0.2)
///     PositionedFill {
///         Text("This content fills the entire parent container.")
///             .background(Color.blue)
///     }
/// }
/// .frame(width: 300, height: 300)
/// ```
///
/// - Parameter content: A view builder that creates the view to fill the parent container.
public struct PositionedFill<Content: View>: View {
    let content: () -> Content

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    public var body: some View {
        GeometryReader { geometry in
            content()
                .frame(width: geometry.size.width, height: geometry.size.height)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }
}

struct PositionedFill_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.gray.opacity(0.2)
            PositionedFill {
                Text("This content fills the entire parent container.")
                    .background(Color.blue)
            }
        }
        .frame(width: 300, height: 300)
    }
}

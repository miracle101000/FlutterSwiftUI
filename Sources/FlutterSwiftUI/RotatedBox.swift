import SwiftUI

/// A view that rotates its child content by a multiple of 90 degrees.
/// This is similar to Flutter's RotatedBox widget.
///
/// Example usage:
/// ```swift
/// RotatedBox(quarterTurns: 1) {
///     Text("Rotated Text")
///         .padding()
///         .background(Color.blue.opacity(0.3))
/// }
/// .frame(width: 200, height: 200)
/// ```
///
/// - Parameters:
///   - quarterTurns: The number of 90-degree turns to apply to the content.
///   - content: A view builder that creates the child view to be rotated.
public struct RotatedBox<Content: View>: View {
    let quarterTurns: Int
    let content: Content

    public init(quarterTurns: Int, @ViewBuilder content: () -> Content) {
        self.quarterTurns = quarterTurns
        self.content = content()
    }
    
    public var body: some View {
        content
            .rotationEffect(Angle(degrees: Double(quarterTurns * 90)))
            .animation(.default, value: quarterTurns) // Optional animation for rotation changes
    }
}

struct RotatedBox_Previews: PreviewProvider {
    static var previews: some View {
        RotatedBox(quarterTurns: 1) {
            Text("Rotated Text")
                .padding()
                .background(Color.blue.opacity(0.3))
        }
        .frame(width: 200, height: 200)
        .border(Color.gray)
    }
}

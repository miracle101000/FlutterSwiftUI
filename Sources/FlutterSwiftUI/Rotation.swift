import SwiftUI

/// A view that rotates its child content by a specified number of full rotations (360° each).
///
/// Example usage:
/// ```swift
/// RotationView(turns: 0.5) { // Rotates by 180°
///     Text("Rotated Text")
///         .padding()
///         .background(Color.green.opacity(0.3))
/// }
/// .frame(width: 200, height: 200)
/// .border(Color.gray)
/// ```
///
/// - Parameter turns: The number of full 360-degree rotations to apply. For example, 1 means 360°,
///                    0.5 means 180°, and so on.
public struct Rotation<Content: View>: View {
    let turns: Double
    let content: Content

    public init(turns: Double, @ViewBuilder content: () -> Content) {
        self.turns = turns
        self.content = content()
    }
    
    public var body: some View {
        content
            .rotationEffect(Angle(degrees: turns * 360))
    }
}

struct Rotation_Previews: PreviewProvider {
    static var previews: some View {
        Rotation(turns: 0.5) { // 0.5 full rotation = 180 degrees
            Text("Rotated Text")
                .padding()
                .background(Color.green.opacity(0.3))
        }
        .frame(width: 200, height: 200)
        .border(Color.gray)
    }
}

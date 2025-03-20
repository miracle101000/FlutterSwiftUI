import SwiftUI

/// A simple horizontal divider that separates content in a layout.
/// You can customize the color, thickness, spacing around the divider,
/// and whether the line is dashed.
///
/// Example usage:
/// ```swift
/// DividerView(
///     color: .red,       // Color of the divider line
///     thickness: 2,      // Thickness of the divider line
///     spacing: 20,       // Vertical spacing above and below the divider
///     dashed: true       // Whether the divider is dashed or solid
/// )
/// ```
///
/// Properties:
/// - `color`: The color of the divider line.
/// - `thickness`: The thickness of the divider line.
/// - `spacing`: The vertical spacing (padding) around the divider.
/// - `dashed`: A Boolean indicating if the line should be dashed.
public struct DividerView: View {
    /// The color of the divider.
    let color: Color
    /// The thickness of the divider line.
    let thickness: CGFloat
    /// The vertical spacing around the divider.
    let spacing: CGFloat
    /// Whether the divider line should be dashed.
    let dashed: Bool
    
    public var body: some View {
        // GeometryReader determines the available width for the line.
        GeometryReader { geometry in
            Path { path in
                // Center the line vertically within the provided height.
                let midY = geometry.size.height / 2
                path.move(to: CGPoint(x: 0, y: midY))
                path.addLine(to: CGPoint(x: geometry.size.width, y: midY))
            }
            .stroke(
                color,
                style: StrokeStyle(
                    lineWidth: thickness,
                    dash: dashed ? [6, 6] : [] // 6 points dash, 6 points gap if dashed
                )
            )
        }
        // Set the height of the divider to the specified thickness.
        .frame(height: thickness)
        // Add vertical padding to create spacing around the divider.
        .padding(.vertical, spacing)
        // Ensure the divider expands to fill the available width.
        .frame(maxWidth: .infinity)
    }
}

struct Divider_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            Text("Above Divider")
                .padding()
            DividerView(color: .blue, thickness: 3, spacing: 20, dashed: false)
            Text("Below Divider")
                .padding()
            DividerView(color: .red, thickness: 2, spacing: 10, dashed: true)
            Text("End of Preview")
                .padding()
        }
        .previewLayout(.sizeThatFits)
    }
}

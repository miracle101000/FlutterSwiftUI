import SwiftUI

/**
 A view that displays a circular progress indicator (spinner).

 This component renders a circular spinner that can be customized in terms of size, color, and line thickness.
 When the `indeterminate` flag is set to true, the spinner rotates continuously, indicating an ongoing process.

 - Parameters:
    - size: The diameter of the progress indicator.
    - color: The color of the spinner.
    - thickness: The line thickness of the circular indicator.
    - indeterminate: A Boolean value that determines whether the spinner rotates continuously.
 
 ## Example usage:
 ```swift
 CircularProgressIndicator(size: 50, color: .blue, thickness: 5, indeterminate: true)
*/ 
public struct CircularProgressIndicator: View {
    let size: CGFloat
    let color: Color
    let thickness: CGFloat
    let indeterminate: Bool

@State private var isAnimating: Bool = false

    public var body: some View {
    ZStack {
        // Background circle (faint)
        Circle()
            .stroke(color, lineWidth: thickness)
            .opacity(0.3)
            .frame(width: size, height: size)
        // Foreground trimmed circle that creates the spinner effect.
        Circle()
            .trim(from: 0, to: 0.75)
            .stroke(
                color,
                style: StrokeStyle(lineWidth: thickness, lineCap: .round)
            )
            .frame(width: size, height: size)
            .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
            .animation(
                indeterminate ?
                Animation.linear(duration: 1.5).repeatForever(autoreverses: false) :
                .default,
                value: isAnimating
            )
            .onAppear {
                if indeterminate {
                    isAnimating = true
                }
            }
    }
  }
}

struct CircularProgressIndicator_Previews: PreviewProvider {
    static var previews: some View {
        CircularProgressIndicator(size: 50, color: .blue, thickness: 5, indeterminate: true)
    }
}

import SwiftUI

/// A view that animates sliding of its children horizontally.
///
/// This component smoothly moves its content along the x-axis by a specified offset over a given duration.
/// The animation is triggered when the view appears.
///
/// - Parameters:
///   - offset: The horizontal distance (in points) to slide the content.
///   - duration: The duration of the animation in seconds (default is 1 second).
///   - onEnd: A closure that is called when the animation completes.
///   - content: The content to be animated.
public struct AnimatedSlide<Content: View>: View {
    @State private var offsetX: CGFloat = 0
    let targetOffset: CGFloat
    let duration: Double
    let onEnd: (() -> Void)?
    let content: Content

    public init(offset: CGFloat, duration: Double = 1.0, onEnd: (() -> Void)? = nil, @ViewBuilder content: () -> Content) {
        self.targetOffset = offset
        self.duration = duration
        self.onEnd = onEnd
        self.content = content()
    }

    public var body: some View {
        content
            .offset(x: offsetX)
            .onAppear {
                // Animate the horizontal slide
                withAnimation(.easeInOut(duration: duration)) {
                    offsetX = targetOffset
                }
                // Trigger the onEnd callback after the animation duration
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    onEnd?()
                }
            }
    }
}

// Example usage
struct AnimatedSlide_Previews: View {
    var body: some View {
        AnimatedSlide(offset: 200, onEnd: {
            print("Animation ended!")
        }) {
            Rectangle()
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
        }
    }
}

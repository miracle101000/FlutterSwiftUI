import SwiftUI

/**
 A view that animates the padding of its content over a specified duration.
 This creates a smooth transition effect when the `padding` value changes.

 - Parameters:
   - padding: The target padding value using `EdgeInsets`.
   - duration: The duration of the animation in seconds.
   - curve: The timing function to control the pace of the animation. Defaults to `.easeInOut`.
   - onEnd: A callback triggered when the animation completes.
   - content: The content to be rendered with animated padding.

 Example usage:
 ```swift
 AnimatedPadding(padding: EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20), duration: 1.0, curve: .easeInOut, onEnd: {
     print("Animation complete")
 }) {
     Rectangle()
         .fill(Color.blue)
         .frame(width: 100, height: 100)
 }
 */
public struct AnimatedPadding<Content: View>: View {
    /// The target padding value for the content.
    let padding: EdgeInsets

    /// The duration of the animation in seconds.
    let duration: Double

    /// The timing function to control the pace of the animation.
    let curve: Animation

    /// A callback triggered when the animation completes.
    let onEnd: (() -> Void)?

    /// The content to be rendered with animated padding.
    let content: Content

    /// The current padding state that drives the animation.
    @State private var currentPadding: EdgeInsets

    public init(
        padding: EdgeInsets,
        duration: Double,
        curve: Animation = .easeInOut,
        onEnd: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.duration = duration
        self.curve = curve
        self.onEnd = onEnd
        self.content = content()
        _currentPadding = State(initialValue: padding)
    }

    public var body: some View {
        content
            .padding(.top, currentPadding.top)
            .padding(.leading, currentPadding.leading)
            .padding(.bottom, currentPadding.bottom)
            .padding(.trailing, currentPadding.trailing)
            .animation(curve, value: currentPadding) // Apply animation to padding changes
            .onAppear {
                // Animate to the target padding when the view appears
                withAnimation(curve) {
                    currentPadding = padding
                }
                // Trigger the onEnd callback after the animation completes
                if let onEnd = onEnd {
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                        onEnd()
                    }
                }
            }
            .onChange(of: padding) { newPadding in
                // Animate to the new padding when the `padding` value changes
                withAnimation(curve) {
                    currentPadding = newPadding
                }
                // Trigger the onEnd callback after the animation completes
                if let onEnd = onEnd {
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                        onEnd()
                    }
                }
            }
    }
}

struct AnimatedPadding_Previews: PreviewProvider {
    static var previews: some View {
        AnimatedPadding(
            padding: EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20),
            duration: 1.0,
            curve: .easeInOut,
            onEnd: {
                print("Animation complete")
            }
        ) {
            Rectangle()
                .fill(Color.blue)
                .frame(width: 100, height: 100)
        }
    }
}

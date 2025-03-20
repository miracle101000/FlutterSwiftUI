import SwiftUI

/**
 A view that animates the opacity of its content over a given duration.

 When the `opacity` value changes, the child view smoothly fades to the new opacity level using an ease-in-out animation.
 An optional `onEnd` callback is triggered after the animation completes.

 - Parameters:
   - opacity: The target opacity value (from 0.0 to 1.0). A value of 0.0 is fully transparent, and 1.0 is fully opaque.
   - duration: The duration of the opacity animation in seconds.
   - onEnd: An optional callback triggered after the animation completes.
   - content: A view builder that defines the content to be animated.
 
 **Example usage:**
 
 ```swift
 AnimatedOpacity(opacity: 0.5, duration: 1.0, onEnd: {
     print("Animation complete")
 }) {
     Rectangle()
         .fill(Color.red)
         .frame(width: 100, height: 100)
 }
 */
public struct AnimatedOpacity<Content: View>: View {
    /// The target opacity for the animation.
    let targetOpacity: Double
    
    /// Duration of the animation in seconds.
    let duration: Double
    
    /// Optional callback to be called after the animation completes.
    let onEnd: (() -> Void)?
    
    /// The content view that will have its opacity animated.
    let content: Content
    
    /// The current opacity state that drives the animation.
    @State private var currentOpacity: Double
    
    public init(
        opacity: Double,
        duration: Double,
        onEnd: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.targetOpacity = opacity
        self.duration = duration
        self.onEnd = onEnd
        self.content = content()
        _currentOpacity = State(initialValue: opacity)
    }
    
    public var body: some View {
        content
            .opacity(currentOpacity)
            .onAppear {
                // Animate to the target opacity when the view appears.
                withAnimation(.easeInOut(duration: duration)) {
                    currentOpacity = targetOpacity
                }
                // Trigger the onEnd callback after the animation completes.
                if let onEnd = onEnd {
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                        onEnd()
                    }
                }
            }
            .onChange(of: targetOpacity) { newOpacity in
                // Animate to the new opacity when the target opacity changes.
                withAnimation(.easeInOut(duration: duration)) {
                    currentOpacity = newOpacity
                }
                // Trigger the onEnd callback after the animation completes.
                if let onEnd = onEnd {
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                        onEnd()
                    }
                }
            }
    }
}

struct AnimatedOpacity_Previews: PreviewProvider {
    static var previews: some View {
        AnimatedOpacity(opacity: 0.5, duration: 1.0, onEnd: {
            print("Animation complete")
        }) {
            Rectangle()
                .fill(Color.red)
                .frame(width: 100, height: 100)
        }
    }
}

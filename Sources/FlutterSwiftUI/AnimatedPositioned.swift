import SwiftUI

/**
 A view that animates the positioning of its child within a container.

 This view uses SwiftUI animations to smoothly transition the position and size of its content.
 You can specify the target left, top, right, bottom, width, and height. When these values change,
 the view will animate to the new configuration.

 Example usage:
 
 ```swift
 AnimatedPositioned(
     left: 50,
     top: 50,
     width: 50,
     height: 50,
     duration: 0.5,
     onEnd: { print("Animation completed!") }
 ) {
     Rectangle()
         .fill(Color.red)
 }
 */
public struct AnimatedPositioned<Content: View>: View {
    /// Optional target position from the left edge.
    let left: CGFloat?
    
    /// Optional target position from the top edge.
    let top: CGFloat?
    
    /// Optional target position from the right edge.
    let right: CGFloat?
    
    /// Optional target position from the bottom edge.
    let bottom: CGFloat?
    
    /// Optional target width.
    let width: CGFloat?
    
    /// Optional target height.
    let height: CGFloat?
    
    /// Animation duration in seconds.
    let duration: Double
    
    /// Callback triggered after the animation completes.
    let onEnd: (() -> Void)?
    
    /// The content view that will be animated.
    let content: Content
    
    /// Internal state variables for animating position and size.
    @State private var currentLeft: CGFloat?
    @State private var currentTop: CGFloat?
    @State private var currentWidth: CGFloat?
    @State private var currentHeight: CGFloat?
    
    public init(
        left: CGFloat? = nil,
        top: CGFloat? = nil,
        right: CGFloat? = nil,
        bottom: CGFloat? = nil,
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        duration: Double = 0.3,
        onEnd: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.left = left
        self.top = top
        self.right = right
        self.bottom = bottom
        self.width = width
        self.height = height
        self.duration = duration
        self.onEnd = onEnd
        self.content = content()
        _currentLeft = State(initialValue: left)
        _currentTop = State(initialValue: top)
        _currentWidth = State(initialValue: width)
        _currentHeight = State(initialValue: height)
    }
    
    public var body: some View {
        GeometryReader { geometry in
            // Compute the x position:
            // If `left` is provided, use it; else, if `right` is provided and width is known,
            // position = parent's width - right - half the width; otherwise, default to 0.
            let posX: CGFloat = {
                if let left = currentLeft, let w = currentWidth {
                    return left + w / 2
                } else if let right = right, let w = currentWidth {
                    return geometry.size.width - right - w / 2
                } else if let w = currentWidth {
                    return w / 2
                } else {
                    return 0
                }
            }()
            
            // Compute the y position similarly:
            let posY: CGFloat = {
                if let top = currentTop, let h = currentHeight {
                    return top + h / 2
                } else if let bottom = bottom, let h = currentHeight {
                    return geometry.size.height - bottom - h / 2
                } else if let h = currentHeight {
                    return h / 2
                } else {
                    return 0
                }
            }()
            
            content
                .frame(width: currentWidth, height: currentHeight)
                .position(x: posX, y: posY)
                .onAppear {
                    // Animate to the target values when the view appears.
                    withAnimation(.easeInOut(duration: duration)) {
                        currentLeft = left
                        currentTop = top
                        currentWidth = width
                        currentHeight = height
                    }
                    // Trigger the onEnd callback after the animation duration.
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                        onEnd?()
                    }
                }
                // Animate changes to left.
                .onChange(of: left) { newValue in
                    withAnimation(.easeInOut(duration: duration)) {
                        currentLeft = newValue
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                        onEnd?()
                    }
                }
                // Animate changes to top.
                .onChange(of: top) { newValue in
                    withAnimation(.easeInOut(duration: duration)) {
                        currentTop = newValue
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                        onEnd?()
                    }
                }
                // Animate changes to width.
                .onChange(of: width) { newValue in
                    withAnimation(.easeInOut(duration: duration)) {
                        currentWidth = newValue
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                        onEnd?()
                    }
                }
                // Animate changes to height.
                .onChange(of: height) { newValue in
                    withAnimation(.easeInOut(duration: duration)) {
                        currentHeight = newValue
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                        onEnd?()
                    }
                }
        }
    }
}

struct AnimatedPositioned_Previews: PreviewProvider {
    static var previews: some View {
        // Example usage within a ZStack (similar to a Stack in React/Flutter)
        ZStack {
            Color(.systemGray6)
                .edgesIgnoringSafeArea(.all)
            
            AnimatedPositioned(
                left: 50,
                top: 50,
                width: 50,
                height: 50,
                duration: 0.5,
                onEnd: {
                    print("Animation completed!")
                }
            ) {
                Rectangle()
                    .fill(Color.red)
            }
        }
        .frame(width: 300, height: 300)
    }
}

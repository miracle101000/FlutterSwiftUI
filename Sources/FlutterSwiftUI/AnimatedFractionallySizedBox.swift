import SwiftUI

/**
 A view that animates its child’s size as a fraction of its parent container’s dimensions.

 The AnimatedFractionallySizedBox takes in width and height factors (ranging from 0 to 1) to compute
 the target size of its child relative to the parent’s size. When the parent’s size or factors change,
 the child’s frame is smoothly animated to the new size.

 - Parameters:
   - widthFactor: A fraction (0...1) of the parent’s width to use as the child’s width (default is 1).
   - heightFactor: A fraction (0...1) of the parent’s height to use as the child’s height (default is 1).
   - duration: The duration of the animation in seconds (default is 0.3 seconds).
   - onEnd: An optional callback that is triggered after the animation completes.
   - content: A view builder that defines the content to be sized and animated.
 
 **Example usage:**
 
 ```swift
 AnimatedFractionallySizedBox(widthFactor: 0.5, heightFactor: 0.3, onEnd: {
     print("Animation complete")
 }) {
     Text("Animated Content")
         .background(Color.blue)
         .foregroundColor(.white)
 }
 .frame(maxWidth: .infinity, maxHeight: .infinity)
*/ 
public struct AnimatedFractionallySizedBox<Content: View>: View {
    let widthFactor: CGFloat
    let heightFactor: CGFloat
    let duration: Double
    let onEnd: (() -> Void)?
    let content: Content


    public init(
    widthFactor: CGFloat = 1,
    heightFactor: CGFloat = 1,
    duration: Double = 0.3,
    onEnd: (() -> Void)? = nil,
    @ViewBuilder content: () -> Content
) {
    self.widthFactor = widthFactor
    self.heightFactor = heightFactor
    self.duration = duration
    self.onEnd = onEnd
    self.content = content()
}

    public var body: some View {
    GeometryReader { geometry in
        let parentSize = geometry.size
        let targetWidth = parentSize.width * widthFactor
        let targetHeight = parentSize.height * heightFactor
        
        ZStack {
            content
                .frame(width: targetWidth, height: targetHeight)
                .animation(.easeInOut(duration: duration), value: targetWidth)
                .animation(.easeInOut(duration: duration), value: targetHeight)
        }
        .frame(width: parentSize.width, height: parentSize.height)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                onEnd?()
            }
        }
        .onChange(of: targetWidth) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                onEnd?()
            }
        }
    }
  }
}

struct AnimatedFractionallySizedBox_Previews: PreviewProvider {
    static var previews: some View {
        AnimatedFractionallySizedBox(
            widthFactor: 0.5,
            heightFactor: 0.3,
            onEnd: {
                print("Animation complete")
            }
        ) {
            Text("Animated Content")
                .background(Color.blue)
                .foregroundColor(.white)
        }
        .frame(width: 300, height: 400)
        .border(Color.gray)
    }
}


import SwiftUI

/// A SwiftUI view that animates its position and size changes based on layout direction.
public struct AnimatedPositionedDirectional<Content: View>: View {
    // MARK: - Properties
    
    /// The content to be displayed inside the animated view.
    let content: Content
    /// The starting horizontal position (leading in LTR, trailing in RTL).
    let start: CGFloat?
    /// The distance from the top.
    let top: CGFloat?
    /// The ending horizontal position (trailing in LTR, leading in RTL).
    let end: CGFloat?
    /// The distance from the bottom.
    let bottom: CGFloat?
    /// The width of the view.
    let width: CGFloat?
    /// The height of the view.
    let height: CGFloat?
    /// The duration of the animation.
    let duration: Double
    /// The layout direction (left-to-right or right-to-left).
    let direction: LayoutDirection
    /// A closure to execute after the animation ends.
    let onEnd: (() -> Void)?
    
    // MARK: - State Variables
    
    /// Tracks the current horizontal position.
    @State private var currentStart: CGFloat?
    /// Tracks the current vertical position.
    @State private var currentTop: CGFloat?
    /// Tracks the current width.
    @State private var currentWidth: CGFloat?
    /// Tracks the current height.
    @State private var currentHeight: CGFloat?
    
    // MARK: - Initializer
    
    /// Initializes the animated positioned view.
    public init(
        start: CGFloat? = nil,
        top: CGFloat? = nil,
        end: CGFloat? = nil,
        bottom: CGFloat? = nil,
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        duration: Double = 0.3,
        direction: LayoutDirection = .leftToRight,
        onEnd: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.start = start
        self.top = top
        self.end = end
        self.bottom = bottom
        self.width = width
        self.height = height
        self.duration = duration
        self.direction = direction
        self.onEnd = onEnd
        self.content = content()
        
        _currentStart = State(initialValue: start)
        _currentTop = State(initialValue: top)
        _currentWidth = State(initialValue: width)
        _currentHeight = State(initialValue: height)
    }
    
    // MARK: - Body
    
    public var body: some View {
        GeometryReader { geometry in
            content
                .frame(
                    width: currentWidth,
                    height: currentHeight
                )
                .position(
                    x: calculateXPosition(parentWidth: geometry.size.width),
                    y: calculateYPosition(parentHeight: geometry.size.height)
                )
                .animation(.easeInOut(duration: duration), value: currentStart)
                .animation(.easeInOut(duration: duration), value: currentTop)
                .animation(.easeInOut(duration: duration), value: currentWidth)
                .animation(.easeInOut(duration: duration), value: currentHeight)
                .onAppear(perform: animateInitialPosition)
                .onChange(of: start) { newValue in animatePositionChange(newValue: newValue) }
                .onChange(of: top) { newValue in animatePositionChange(newValue: newValue) }
                .onChange(of: width) { newValue in animateSizeChange(newValue: newValue) }
                .onChange(of: height) { newValue in animateSizeChange(newValue: newValue) }
        }
    }
    
    // MARK: - Position Calculations
    
    /// Calculates the X position based on the layout direction.
    private func calculateXPosition(parentWidth: CGFloat) -> CGFloat {
        switch direction {
        case .leftToRight:
            if let start = currentStart, let width = currentWidth {
                return start + (width / 2)
            }
            if let end = end, let width = currentWidth {
                return parentWidth - end - (width / 2)
            }
            return 0
            
        case .rightToLeft:
            if let end = end, let width = currentWidth {
                return parentWidth - end - (width / 2)
            }
            if let start = currentStart, let width = currentWidth {
                return start + (width / 2)
            }
            return 0
        @unknown default:
            fatalError()
        }
    }
    
    /// Calculates the Y position.
    private func calculateYPosition(parentHeight: CGFloat) -> CGFloat {
        if let top = currentTop, let height = currentHeight {
            return top + (height / 2)
        }
        if let bottom = bottom, let height = currentHeight {
            return parentHeight - bottom - (height / 2)
        }
        return 0
    }
    
    // MARK: - Animation Handlers
    
    /// Handles the initial animation when the view appears.
    private func animateInitialPosition() {
        withAnimation(.easeInOut(duration: duration)) {
            currentStart = start
            currentTop = top
            currentWidth = width
            currentHeight = height
        }
        triggerEndCallback()
    }
    
    /// Animates position changes.
    private func animatePositionChange(newValue: CGFloat?) {
        withAnimation(.easeInOut(duration: duration)) {
            currentStart = newValue
            currentTop = newValue
        }
        triggerEndCallback()
    }
    
    /// Animates size changes.
    private func animateSizeChange(newValue: CGFloat?) {
        withAnimation(.easeInOut(duration: duration)) {
            currentWidth = newValue
            currentHeight = newValue
        }
        triggerEndCallback()
    }
    
    /// Triggers the callback function after animation ends.
    private func triggerEndCallback() {
        guard let onEnd = onEnd else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            onEnd()
        }
    }
}

// MARK: - Preview

struct AnimatedPositionedDirectional_Previews: PreviewProvider {
    @State static var position = CGPoint(x: 50, y: 50)
    
    static var previews: some View {
        VStack {
            Button("Move Box") {
                position = CGPoint(
                    x: CGFloat.random(in: 0...250),
                    y: CGFloat.random(in: 0...250)
                )
            }
            
            ZStack {
                Color.blue.opacity(0.2)
                    .frame(width: 300, height: 300)
                
                AnimatedPositionedDirectional(
                    start: position.x,
                    top: position.y,
                    width: 50,
                    height: 50,
                    duration: 0.5,
                    direction: .leftToRight,
                    onEnd: {
                        print("Animation completed!")
                    }
                ) {
                    Rectangle()
                        .fill(.red)
                }
            }
            .frame(width: 300, height: 300)
        }
    }
}

import SwiftUI

/// A SwiftUI view that animates the scaling of its content.
///
/// Example usage:
/// ```swift
/// AnimatedScale(scale: 1.5, duration: 1.0, onEnd: {
///     print("Animation ended!")
/// }) {
///     Rectangle()
///         .fill(Color.blue)
///         .frame(width: 100, height: 100)
/// }
/// ```

public struct AnimatedScale<Content: View>: View {
    let scale: CGFloat
    let duration: Double
    let onEnd: (() -> Void)?
    let content: Content
    
    @State private var currentScale: CGFloat
    
    public init(scale: CGFloat, duration: Double = 1.0, onEnd: (() -> Void)? = nil, @ViewBuilder content: () -> Content) {
        self.scale = scale
        self.duration = duration
        self.onEnd = onEnd
        self.content = content()
        _currentScale = State(initialValue: 1.0) // Start at normal scale
    }
    
    public var body: some View {
        content
            .scaleEffect(currentScale)
            .animation(.easeInOut(duration: duration), value: currentScale)
            .onAppear {
                animateScale()
            }
            .onChange(of: scale) { newValue in
                animateScale(to: newValue)
            }
    }
    
    private func animateScale(to newScale: CGFloat? = nil) {
        withAnimation(.easeInOut(duration: duration)) {
            currentScale = newScale ?? scale
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            onEnd?()
        }
    }
}

// MARK: - Preview
struct AnimatedScale_Previews: PreviewProvider {
    static var previews: some View {
        AnimatedScale(scale: 1.5, duration: 1.0) {
            Rectangle()
                .fill(Color.blue)
                .frame(width: 100, height: 100)
        }
    }
}

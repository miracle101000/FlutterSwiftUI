import SwiftUI

public struct AnimatedRotation<Content: View>: View {
    // MARK: - Properties
    let turns: Double // The number of 360-degree rotations
    let duration: Double // Duration of the animation in seconds
    let content: Content
    let onEnd: (() -> Void)?
    
    // MARK: - State
    @State private var rotationAngle: Double = 0
    
    // MARK: - Initializer
    public init(turns: Double, duration: Double, onEnd: (() -> Void)? = nil, @ViewBuilder content: () -> Content) {
        self.turns = turns
        self.duration = duration
        self.onEnd = onEnd
        self.content = content()
    }
    
    // MARK: - Body
    public var body: some View {
        content
            .rotationEffect(.degrees(rotationAngle))
            .animation(.easeInOut(duration: duration), value: rotationAngle)
            .onAppear {
                rotate()
            }
            .onChange(of: turns) { _ in
                rotate()
            }
    }
    
    // MARK: - Rotation Logic
    private func rotate() {
        let newAngle = turns * 360
        withAnimation(.easeInOut(duration: duration)) {
            rotationAngle = newAngle
        }
        
        if let onEnd = onEnd {
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                onEnd()
            }
        }
    }
}

// MARK: - Preview
struct AnimatedRotation_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            AnimatedRotation(turns: 2, duration: 1.0, onEnd: {
                print("Animation completed!")
            }) {
                Rectangle()
                    .fill(Color.red)
                    .frame(width: 100, height: 100)
            }
        }
    }
}

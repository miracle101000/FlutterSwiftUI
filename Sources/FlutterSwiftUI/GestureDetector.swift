
import SwiftUI

/**
 A view that detects various user gestures such as tap, double tap, long press, and drag updates.
 
 This view wraps any content and allows you to supply callbacks for:
 - `onTap`: Called when the user taps once.
 - `onDoubleTap`: Called when the user double taps.
 - `onLongPress`: Called when the user holds for a specified delay.
 - `onPanUpdate`: Called continuously with the drag (pan) update position.
 - `onVerticalDragUpdate`: Called with drag updates (vertical movement).
 - `onHorizontalDragUpdate`: Called with drag updates (horizontal movement).
 
 The `longPressDelay` parameter specifies the duration (in milliseconds) to wait before
 triggering the long press action (default is 500ms).
 
 Example usage:
 
 ```swift
 struct ContentView: View {
     var body: some View {
         GestureDetector(
             onTap: { print("Tapped!") },
             onDoubleTap: { print("Double Tapped!") },
             onLongPress: { print("Long Pressed!") },
             onPanUpdate: { pos in print("Dragging at: \(pos)") },
             longPressDelay: 700
         ) {
             Rectangle()
                 .fill(Color.red)
                 .frame(width: 100, height: 100)
         }
         .padding()
     }
 }
 ```
 */
public struct GestureDetector<Content: View>: View {
    // MARK: - Gesture Callbacks
    let onTap: (() -> Void)?
    let onDoubleTap: (() -> Void)?
    let onLongPress: (() -> Void)?
    let onPanUpdate: ((CGPoint) -> Void)?
    let onVerticalDragUpdate: ((CGPoint) -> Void)?
    let onHorizontalDragUpdate: ((CGPoint) -> Void)?
    
    /// The delay for the long press gesture in milliseconds.
    let longPressDelay: Double
    
    // MARK: - Content
    let content: Content
    
    public init(
        onTap: (() -> Void)? = nil,
        onDoubleTap: (() -> Void)? = nil,
        onLongPress: (() -> Void)? = nil,
        onPanUpdate: ((CGPoint) -> Void)? = nil,
        onVerticalDragUpdate: ((CGPoint) -> Void)? = nil,
        onHorizontalDragUpdate: ((CGPoint) -> Void)? = nil,
        longPressDelay: Double = 500,
        @ViewBuilder content: () -> Content
    ) {
        self.onTap = onTap
        self.onDoubleTap = onDoubleTap
        self.onLongPress = onLongPress
        self.onPanUpdate = onPanUpdate
        self.onVerticalDragUpdate = onVerticalDragUpdate
        self.onHorizontalDragUpdate = onHorizontalDragUpdate
        self.longPressDelay = longPressDelay
        self.content = content()
    }
    
    public var body: some View {
        // Start with the wrapped content.
        content
            // High priority double tap gesture.
            .highPriorityGesture(
                TapGesture(count: 2)
                    .onEnded {
                        onDoubleTap?()
                    }
            )
            // Single tap gesture. (Executed if double tap does not occur.)
            .onTapGesture {
                onTap?()
            }
            // Attach a long press gesture with a configurable delay.
            .simultaneousGesture(
                LongPressGesture(minimumDuration: longPressDelay / 1000)
                    .onEnded { _ in
                        onLongPress?()
                    }
            )
            // Attach a drag gesture to detect pan updates.
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        // The location of the drag gesture in the view's coordinate space.
                        let position = value.location
                        onPanUpdate?(position)
                        
                        // For vertical drag updates, you can choose to send the same value.
                        onVerticalDragUpdate?(position)
                        
                        // For horizontal drag updates, likewise.
                        onHorizontalDragUpdate?(position)
                    }
            )
    }
}

struct GestureDetector_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 30) {
            GestureDetector(
                onTap: { print("Tapped!") },
                onDoubleTap: { print("Double Tapped!") },
                onLongPress: { print("Long Pressed!") },
                onPanUpdate: { pos in print("Pan update at: \(pos)") },
                longPressDelay: 700
            ) {
                Rectangle()
                    .fill(Color.red.opacity(0.5))
                    .frame(width: 150, height: 150)
                    .overlay(Text("Gesture Area"))
            }
            .border(Color.gray)
            
            Text("Interact with the red square in the console.")
                .font(.caption)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}


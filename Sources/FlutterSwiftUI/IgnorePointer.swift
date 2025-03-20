
import SwiftUI

/**
 A view that conditionally ignores pointer events (such as taps or gestures) for its child content.
 
 When `shouldIgnore` is set to `true`, the view disables hit testing for its children, meaning that
 no touch or click events will be detected. When `shouldIgnore` is `false`, pointer events are allowed.
 
 This is analogous to Flutter's `IgnorePointer` widget.
 
 Example usage:
 
 ```swift
 struct ContentView: View {
     var body: some View {
         IgnorePointer(shouldIgnore: true) {
             Rectangle()
                 .fill(Color.blue.opacity(0.3))
                 .frame(width: 200, height: 200)
         }
     }
 }
 ```
 
 - Parameter shouldIgnore: A Boolean value determining whether pointer events are ignored.
 Defaults to `true`.
 - Parameter content: The child view on which to apply the hit testing behavior.
 */
public struct IgnorePointer<Content: View>: View {
    let shouldIgnore: Bool
    let content: Content
    
    public init(shouldIgnore: Bool = true, @ViewBuilder content: () -> Content) {
        self.shouldIgnore = shouldIgnore
        self.content = content()
    }
    
    public var body: some View {
        content.allowsHitTesting(!shouldIgnore)
    }
}

struct IgnorePointer_Previews: PreviewProvider {
    static var previews: some View {
        IgnorePointer(shouldIgnore: true) {
            Text("This view ignores pointer events.")
                .padding()
                .background(Color.yellow)
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}

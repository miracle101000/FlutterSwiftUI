
import SwiftUI

/**
 A view that limits its size based on the provided `maxWidth` and `maxHeight`.
 
 This view is useful when you want to ensure that its content does not exceed a specified size,
 but it is allowed to shrink if the parent's constraints or content dictate.
 
 If `maxWidth` or `maxHeight` is `nil`, no limit is applied for that dimension.
 
 Example usage:
 
 ```swift
 struct ContentView: View {
     var body: some View {
         LimitedBox(maxWidth: 300, maxHeight: 200) {
             Text("This content is inside a box with limited size.")
                 .padding()
                 .border(Color.black)
         }
         .padding()
     }
 }
 ```
 
 - Parameters:
   - `maxWidth`: The maximum width of the box. Pass `nil` for no width limit.
   - `maxHeight`: The maximum height of the box. Pass `nil` for no height limit.
   - `content`: A view builder closure that provides the content to be displayed inside the box.
 */
public struct LimitedBox<Content: View>: View {
    let maxWidth: CGFloat?
    let maxHeight: CGFloat?
    let content: Content
    
    public  init(maxWidth: CGFloat? = nil,
         maxHeight: CGFloat? = nil,
         @ViewBuilder content: () -> Content) {
        self.maxWidth = maxWidth
        self.maxHeight = maxHeight
        self.content = content()
    }
    
    public var body: some View {
        content
            .frame(maxWidth: maxWidth, maxHeight: maxHeight)
    }
}

struct LimitedBox_Previews: PreviewProvider {
    static var previews: some View {
        LimitedBox(maxWidth: 300, maxHeight: 200) {
            Text("This content is inside a box with limited size.")
                .padding()
                .border(Color.black)
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}


import SwiftUI

/**
 A view that expands to fill the available space within a flexible container,
 similar to Flutter's `Expanded` widget.
 
 You can optionally supply a flex factor to indicate the relative amount of space
 that this view should take compared to its siblings. In an HStack or VStack,
 views with higher flex values will be given a higher layout priority.
 
 Example usage:
 
 ```swift
 struct MyComponent: View {
     var body: some View {
         HStack {
             Text("Item 1")
             Expanded(flex: 2) {
                 Text("Item 2 (Expanded with flex 2)")
                     .background(Color.green.opacity(0.3))
             }
             Expanded {
                 Text("Item 3 (Expanded with flex 1)")
                     .background(Color.blue.opacity(0.3))
             }
             Text("Item 4")
         }
         .padding()
         .border(Color.gray)
     }
 }
 ```
 
 - Parameters:
    - flex: An integer value determining how much space the view should occupy relative to its siblings (default is 1).
    - content: A view builder that provides the content to be expanded.
 */
public struct Expanded<Content: View>: View {
    let flex: Int
    let content: Content
    
    init(flex: Int = 1, @ViewBuilder content: () -> Content) {
        self.flex = flex
        self.content = content()
    }
    
    public var body: some View {
        content
            // Expand horizontally (or vertically in a VStack) to fill available space.
            .frame(maxWidth: .infinity)
            // Use layoutPriority to influence how much extra space is allocated.
            .layoutPriority(Double(flex))
    }
}

struct Expanded_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Above Expanded")
                .padding(.bottom, 10)
            
            HStack(spacing: 0) {
                Text("Item 1")
                    .padding()
                    .background(Color.yellow.opacity(0.3))
                
                Expanded(flex: 2) {
                    Text("Item 2 (flex: 2)")
                        .padding()
                        .background(Color.green.opacity(0.3))
                }
                
                Expanded {
                    Text("Item 3 (flex: 1)")
                        .padding()
                        .background(Color.blue.opacity(0.3))
                }
                
                Text("Item 4")
                    .padding()
                    .background(Color.orange.opacity(0.3))
            }
            .border(Color.gray)
            
            Text("Below Expanded")
                .padding(.top, 10)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}



import SwiftUI

/**
 A view that sizes its child based on a fraction of the parent container's width and height.
 
 This is similar to Flutter's FractionallySizedBox (or the provided React component), allowing you
 to specify a `widthFactor` and `heightFactor` (typically between 0 and 1) to scale the child view relative
 to the parent's size.
 
 In this implementation, a GeometryReader is used to capture the parent's dimensions. The child view is then
 given a fixed frame based on the parent's width and height multiplied by the provided factors.
 
 Example usage:
 
 ```swift
 struct ExampleView: View {
     var body: some View {
         FractionallySizedBox(widthFactor: 0.5, heightFactor: 0.3) {
             Text("This is a fractionally sized box.")
                 .multilineTextAlignment(.center)
                 .background(Color.blue.opacity(0.3))
         }
         .frame(width: 300, height: 300)
         .border(Color.black)
     }
 }
 ```
 
 - Parameters:
    - widthFactor: The fraction of the parent's width to use (default is 1, i.e. 100%).
    - heightFactor: The fraction of the parent's height to use (default is 1, i.e. 100%).
    - content: A view builder that produces the child view to be sized.
 */
public struct FractionallySizedBox<Content: View>: View {
    let widthFactor: CGFloat
    let heightFactor: CGFloat
    let content: Content
    
    public init(widthFactor: CGFloat = 1,
         heightFactor: CGFloat = 1,
         @ViewBuilder content: () -> Content) {
        self.widthFactor = widthFactor
        self.heightFactor = heightFactor
        self.content = content()
    }
    
    public var body: some View {
        GeometryReader { geometry in
            // Calculate desired dimensions based on parent's size.
            let desiredWidth = geometry.size.width * widthFactor
            let desiredHeight = geometry.size.height * heightFactor
            
            // Use a ZStack with topLeading alignment to mimic a "relative" container.
            ZStack(alignment: .topLeading) {
                // This clear color fills the parent's area.
                Color.clear
                // The child is sized to the computed dimensions.
                content
                    .frame(width: desiredWidth, height: desiredHeight)
            }
        }
    }
}

struct FractionallySizedBox_Previews: PreviewProvider {
    static var previews: some View {
        FractionallySizedBox(widthFactor: 0.5, heightFactor: 0.3) {
            Text("This is a fractionally sized box.")
                .multilineTextAlignment(.center)
                .background(Color.blue.opacity(0.3))
        }
        .frame(width: 300, height: 300)
        .border(Color.black)
        .padding()
        .previewLayout(.sizeThatFits)
    }
}

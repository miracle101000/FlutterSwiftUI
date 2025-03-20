import SwiftUI

/**
 A view that centers its content both horizontally and vertically within the available space.

 The `Center` component behaves like a container with CSS Flexbox properties `justifyContent: center` and `alignItems: center`.
 It automatically fills the available width and height of its parent, ensuring that the content is perfectly centered.

 - Parameter content: A view builder that creates the content to be centered.

 ## Example usage:
 ```swift
 Center {
     Text("Centered Content")
         .font(.title)
         .padding()
         .background(Color.blue)
         .foregroundColor(.white)
 }
*/ 

public struct Center<Content: View>: View {
let content: Content

    public init(@ViewBuilder content: () -> Content) {
    self.content = content()
}

    public var body: some View {
    GeometryReader { geometry in
        content
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
    }
 }
}

struct Center_Previews: PreviewProvider {
    static var previews: some View {
        Center {
            Text("Centered Content")
                .font(.title)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
        } .background(Color.gray.opacity(0.3))
    }
}

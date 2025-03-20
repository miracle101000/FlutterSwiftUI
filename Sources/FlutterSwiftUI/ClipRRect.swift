import SwiftUI

/**
 A view that clips its content into a rounded rectangle.

 The `ClipRRect` view is useful for applying rounded corners to any content. You can specify the corner radius.

 - Parameters:
    - radius: The corner radius of the rounded rectangle.
    - content: A view builder that produces the content to be clipped.

 ## Example usage:
 ```swift
 ClipRRect(radius: 20) {
     Image("exampleImage")
         .resizable()
         .scaledToFill()
 }
 .frame(width: 200, height: 200)
*/ 
public struct ClipRRect<Content: View>: View {
    let radius: CGFloat
    let content: Content

    public init(radius: CGFloat, @ViewBuilder content: () -> Content) {
    self.radius = radius
    self.content = content()
}

    public var body: some View {
    content
        .clipShape(RoundedRectangle(cornerRadius: radius))
  }
}

struct ClipRRect_Previews: PreviewProvider { 
    static var previews: some View {
        VStack(spacing: 20) {
            ClipRRect(radius: 20) {
                Image("exampleImage")
                    .resizable()
                    .scaledToFill()
            } .frame(width: 200, height: 200) .border(Color.gray)

        ClipRRect(radius: 20) {
            Image("exampleImage")
                .resizable()
                .scaledToFill()
        }
        .frame(width: 200, height: 200)
        .border(Color.gray)
    }
    .previewLayout(.sizeThatFits)
  }
}

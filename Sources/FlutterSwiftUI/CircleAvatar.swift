import SwiftUI

/**
 A circular avatar view similar to Flutter's `CircleAvatar` widget.
 
 The `CircleAvatar` component displays an avatar with a background color, an optional background image (from a URL or a local asset), and optional overlay content.
 It also allows you to customize the border color and thickness.
 
 ## Features:
 - Background color fallback if no image is provided.
 - Option to display a local image (using asset name) or a remote image (using `AsyncImage`).
 - Customizable border color and thickness.
 - Supports overlay content (e.g., text or icons) on top of the avatar.
 
 ### Example Usage:
 ```swift
 // Avatar with background color and border
 CircleAvatar(size: 60, backgroundColor: .teal, borderColor: .black, borderThickness: 2)
 
 // Avatar with background image from a URL and border
 CircleAvatar(size: 80, backgroundImageURL: URL(string: "https://via.placeholder.com/150"), borderColor: .red, borderThickness: 3)
 
 // Avatar with a local background image and overlay text
 CircleAvatar(size: 100, backgroundImage: "profile_picture", borderColor: .blue, borderThickness: 4) {
     Text("B")
         .font(.title)
         .fontWeight(.bold)
         .foregroundColor(.white)
 }
*/ 
public struct CircleAvatar<Content: View>: View {
    let size: CGFloat
    let backgroundColor: Color
    let backgroundImage: Image?
    let backgroundImageURL: URL?
    let borderColor: Color
    let borderThickness: CGFloat
    let content: Content

/**
 Initializes a `CircleAvatar` with customizable properties.
 
 - Parameters:
   - size: The diameter of the avatar in points. Defaults to `50`.
   - backgroundColor: The background color of the avatar. Defaults to `.gray`.
   - backgroundImage: An optional asset name for a local background image.
   - backgroundImageURL: An optional `URL` for a remote background image.
   - borderColor: The color of the avatar's border. Defaults to `.clear` (no border).
   - borderThickness: The thickness of the border in points. Defaults to `0` (no border).
   - content: An optional view to overlay inside the avatar. Defaults to `EmptyView`.
 */
    public init(
    size: CGFloat = 50,
    backgroundColor: Color = .gray,
    backgroundImage: String? = nil,
    backgroundImageURL: URL? = nil,
    borderColor: Color = .clear,
    borderThickness: CGFloat = 0,
    @ViewBuilder content: () -> Content = { EmptyView() }
) {
    self.size = size
    self.backgroundColor = backgroundColor
    // If a local image name is provided, create an Image from it.
    if let bgImageName = backgroundImage {
        self.backgroundImage = Image(bgImageName)
    } else {
        self.backgroundImage = nil
    }
    self.backgroundImageURL = backgroundImageURL
    self.borderColor = borderColor
    self.borderThickness = borderThickness
    self.content = content()
}

    public var body: some View {
    ZStack {
        // Background: use a local image if provided; if not, check for a remote URL; otherwise, fallback to a solid color.
        if let backgroundImage = backgroundImage {
            backgroundImage
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
                .clipShape(Circle())
        } else if let backgroundImageURL = backgroundImageURL {
            AsyncImage(url: backgroundImageURL) { phase in
                if let image = phase.image {
                    image.resizable()
                        .scaledToFill()
                } else if phase.error != nil {
                    // On error, fallback to background color
                    Color.clear
                } else {
                    // While loading, show a progress view or empty view
                    ProgressView()
                }
            }
            .frame(width: size, height: size)
            .clipShape(Circle())
        } else {
            Circle()
                .fill(backgroundColor)
        }
        
        // Overlay content if any.
        content
    }
    .frame(width: size, height: size)
    .clipShape(Circle())
    .overlay(
        Circle()
            .stroke(borderColor, lineWidth: borderThickness)
    )
 }
}

struct CircleAvatar_Previews: PreviewProvider { 
    static var previews: some View {
        VStack(spacing: 20) { 
            // Avatar with background color and border
            CircleAvatar(size: 60, backgroundColor: .teal, borderColor: .black, borderThickness: 2)

        // Avatar with remote background image and border
        CircleAvatar(size: 80, backgroundImageURL: URL(string: "https://via.placeholder.com/150"), borderColor: .red, borderThickness: 3)
        
        // Avatar with local background image and overlay text
        CircleAvatar(size: 100, backgroundImage: "profile_picture", borderColor: .blue, borderThickness: 4) {
            Text("B")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }
    .padding()
    .background(Color.gray.opacity(0.3))
 }
}

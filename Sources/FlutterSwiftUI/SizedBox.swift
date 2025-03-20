import SwiftUI

/// A view that enforces a fixed width and height on its content, similar to Flutter's SizedBox.
/// It also allows you to apply external horizontal and vertical margins.
///
/// Example usage:
/// ```swift
/// // Fixed size with a background color
/// SizedBox(width: 100, height: 100) {
///     Text("Fixed Size")
///         .frame(maxWidth: .infinity, maxHeight: .infinity)
///         .background(Color.blue.opacity(0.3))
/// }
///
/// // Using percentage width and fixed height (converted to a CGFloat)
/// SizedBox(width: UIScreen.main.bounds.width * 0.5, height: 200, marginHorizontal: 10, marginVertical: 20) {
///     Text("Half Screen Width, 200 Height")
///         .background(Color.green.opacity(0.3))
/// }
/// ```
///
/// - Parameters:
///   - width: The fixed width of the view. Defaults to nil (auto width).
///   - height: The fixed height of the view. Defaults to nil (auto height).
///   - marginHorizontal: Horizontal margin (applied as padding) around the view.
///   - marginVertical: Vertical margin (applied as padding) around the view.
///   - content: A view builder that produces the content to be sized.
public struct SizedBox<Content: View>: View {
    let width: CGFloat?
    let height: CGFloat?
    let marginHorizontal: CGFloat?
    let marginVertical: CGFloat?
    let content: Content?

    public init(
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        marginHorizontal: CGFloat? = nil,
        marginVertical: CGFloat? = nil,
        @ViewBuilder content: () -> Content? = { nil }
    ) {
        self.width = width
        self.height = height
        self.marginHorizontal = marginHorizontal
        self.marginVertical = marginVertical
        self.content = content()
    }

    public var body: some View {
        Group {
            if let content = content {
                content
            } else {
                EmptyView()
            }
        }
        .frame(width: width, height: height)
        .padding(.horizontal, marginHorizontal ?? 0)
        .padding(.vertical, marginVertical ?? 0)
    }
}

struct SizedBox_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            SizedBox(width: 100, height: 100) {
                Text("Fixed Size")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.blue.opacity(0.3))
            }
            .border(Color.gray)
            
            SizedBox(width: UIScreen.main.bounds.width * 0.5, height: 200, marginHorizontal: 10, marginVertical: 20) {
                Text("Half Screen Width, 200 Height")
                    .background(Color.green.opacity(0.3))
            }
            .border(Color.gray)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}

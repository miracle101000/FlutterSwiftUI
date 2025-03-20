import SwiftUI


/// A view that arranges its children in a vertical column (using VStack),
/// with configurable padding, margin, and alignment. This is similar to a flex container
/// with a column direction in React.
///
/// Example usage:
/// ```swift
/// Column(
///     mainAxisAlignment: .center,
///     crossAxisAlignment: .center
/// ) {
///     Rectangle()
///         .fill(Color.red)
///         .frame(width: 50, height: 50)
///     Rectangle()
///         .fill(Color.blue)
///         .frame(width: 50, height: 50)
///     Rectangle()
///         .fill(Color.green)
///         .frame(width: 50, height: 50)
/// }
/// .border(Color.gray)
/// ```
///
/// - Parameters:
///   - padding: The internal padding applied to the Column's content.
///   - margin: The external margin around the Column.
///   - mainAxisAlignment: The vertical alignment of children. Supported values are
///                         `.flexStart`, `.center`, `.flexEnd`. (The spacing modes
///                         spaceBetween/spaceAround are not implemented here.)
///   - crossAxisAlignment: The horizontal alignment of children. Maps to:
///         - `.flexStart` → leading,
///         - `.center` → center,
///         - `.flexEnd` → trailing,
///         - `.stretch` → makes children expand horizontally.
///   - width: An optional fixed width for the Column.
///   - height: An optional fixed height for the Column.
///   - content: A view builder that creates the Column’s child views.
public struct Column<Content: View>: View {
    let mainAxisAlignment: MainAxisAlignment
    let crossAxisAlignment: CrossAxisAlignment
    let mainAxisSize: MainAxisSize
    let spacing: CGFloat
    let content: Content

    public init(
        mainAxisAlignment: MainAxisAlignment = .start,
        crossAxisAlignment: CrossAxisAlignment = .stretch,
        mainAxisSize: MainAxisSize = .max,
        spacing: CGFloat = 0,
        @ViewBuilder content: () -> Content
    ) {
        self.mainAxisAlignment = mainAxisAlignment
        self.crossAxisAlignment = crossAxisAlignment
        self.mainAxisSize = mainAxisSize
        self.spacing = spacing
        self.content = content()
    }
    
    /// Convert our custom cross axis alignment to SwiftUI's HorizontalAlignment.
    private var horizontalAlignment: HorizontalAlignment {
        switch crossAxisAlignment {
        case .start:
            return .leading
        case .center, .stretch, .baseline:
            return .center
        case .end:
            return .trailing
        }
    }
    
    public var body: some View {
        VStack(alignment: horizontalAlignment, spacing: spacing) {
            if mainAxisAlignment == .end || mainAxisAlignment == .center {
                Spacer()
            }
            
            content
            
            if mainAxisAlignment == .start || mainAxisAlignment == .center {
                Spacer()
            }
        }
        .frame(maxHeight: mainAxisSize == .max ? .infinity : nil)
    }
}


struct Column_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            Column(
                mainAxisAlignment: .center,
                crossAxisAlignment: .center
            ) {
                Rectangle()
                    .fill(Color.red)
                    .frame(width: 50, height: 50)
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: 50, height: 50)
                Rectangle()
                    .fill(Color.green)
                    .frame(width: 50, height: 50)
            }
            .border(Color.gray)
        }
        .previewLayout(.sizeThatFits)
    }
}

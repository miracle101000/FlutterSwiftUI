import SwiftUI

/// A view that arranges its children in a horizontal row with customizable alignment,
/// spacing, and layout direction. This is similar to a flex container in React with row direction.
///
/// Example usage:
/// ```swift
/// Row(
///     mainAxisAlignment: .center,
///     crossAxisAlignment: .center,
///     spacing: 20
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
/// .frame(height: 100)
/// ```
///
/// - Parameters:
///   - mainAxisAlignment: Determines the horizontal alignment of the children (defaults to `.start`).
///   - crossAxisAlignment: Determines the vertical alignment of the children (defaults to `.stretch`).
///   - mainAxisSize: Determines whether the Row should expand to fill the available width (`.max`)
///                   or take the minimum size (`.min`). Defaults to `.max`.
///   - textDirection: The layout direction, either `.leftToRight` or `.rightToLeft`. Defaults to `.leftToRight`.
///   - spacing: The space between children (defaults to 0).
///   - content: A view builder that produces the row's child views.
public struct Row<Content: View>: View {
    let mainAxisAlignment: MainAxisAlignment
    let crossAxisAlignment: CrossAxisAlignment
    let mainAxisSize: MainAxisSize
    let textDirection: LayoutDirection
    let spacing: CGFloat
    let content: Content

    public init(
        mainAxisAlignment: MainAxisAlignment = .start,
        crossAxisAlignment: CrossAxisAlignment = .stretch,
        mainAxisSize: MainAxisSize = .max,
        textDirection: LayoutDirection = .leftToRight,
        spacing: CGFloat = 0,
        @ViewBuilder content: () -> Content
    ) {
        self.mainAxisAlignment = mainAxisAlignment
        self.crossAxisAlignment = crossAxisAlignment
        self.mainAxisSize = mainAxisSize
        self.textDirection = textDirection
        self.spacing = spacing
        self.content = content()
    }
    
    public var body: some View {
        HStack(alignment: verticalAlignment(), spacing: spacing) {
            content
        }
        // For mainAxisSize, if max, let the row expand.
        .frame(maxWidth: mainAxisSize == .max ? .infinity : nil,
               alignment: horizontalAlignment())
        .environment(\.layoutDirection, textDirection)
    }
    
    /// Maps MainAxisAlignment to a SwiftUI Alignment value.
    /// For unsupported cases, default to center.
    private func horizontalAlignment() -> Alignment {
        switch mainAxisAlignment {
        case .start:
            return .leading
        case .end:
            return .trailing
        case .center:
            return .center
        case .spaceBetween, .spaceAround, .spaceEvenly:
            return .center
        }
    }
    
    /// Maps CrossAxisAlignment to a SwiftUI VerticalAlignment.
    private func verticalAlignment() -> VerticalAlignment {
        switch crossAxisAlignment {
        case .start:
            return .top
        case .end:
            return .bottom
        case .center, .stretch:
            return .center
        case .baseline:
            return .firstTextBaseline
        }
    }
}

struct Row_Previews: PreviewProvider {
    static var previews: some View {
        Row(
            mainAxisAlignment: .center,
            crossAxisAlignment: .center,
            spacing: 20
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
        .frame(height: 100)
        .border(Color.gray)
        .previewLayout(.sizeThatFits)
    }
}

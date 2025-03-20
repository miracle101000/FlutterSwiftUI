import SwiftUI

/// An enum that specifies how the child view is scaled to fit within the container.
///
/// - contain: Scales the child so that it fits entirely within the container (no clipping).
/// - cover: Scales the child so that it completely covers the container (parts may be clipped).
public enum FittedBoxFit {
    case contain
    case cover
}

/// A view that scales and aligns its child to fit within the available space,
/// similar to Flutter's FittedBox.
///
/// The view measures both the container and child sizes to compute a scale factor.
/// Depending on the selected `fit` option, the scale is chosen as either the minimum
/// (for `.contain`) or maximum (for `.cover`) of the horizontal and vertical scaling factors.
///
/// Use the `alignment` parameter to control how the child is positioned within the container.
/// SwiftUI’s built‑in alignments (such as `.center`, `.topLeading`, `.bottomTrailing`, etc.)
/// are supported.
///
/// Example usage:
/// ```swift
/// struct ExampleView: View {
///     var body: some View {
///         // A container of fixed size
///         ZStack {
///             Color.gray.opacity(0.2)
///             FittedBox(fit: .contain, alignment: .center) {
///                 // A child view with its own intrinsic size.
///                 Text("Hello, FittedBox!")
///                     .padding()
///                     .background(Color.blue)
///             }
///         }
///         .frame(width: 300, height: 300)
///         .border(Color.black)
///     }
/// }
/// ```
public struct FittedBox<Content: View>: View {
    /// How the child should be scaled within the container.
    let fit: FittedBoxFit
    /// The alignment used for positioning the child in the container.
    let alignment: Alignment
    /// The content to be scaled and aligned.
    let content: () -> Content

    /// The intrinsic size of the child view.
    @State private var childSize: CGSize = .zero

    public init(
        fit: FittedBoxFit = .contain,
        alignment: Alignment = .center,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.fit = fit
        self.alignment = alignment
        self.content = content
    }

    public var body: some View {
        GeometryReader { containerProxy in
            // Capture the container size.
            let containerSize = containerProxy.size
            ZStack(alignment: alignment) {
                content()
                    // Use a background GeometryReader to measure the child's intrinsic size.
                    .background(
                        GeometryReader { childProxy in
                            Color.clear
                                .preference(key: SizePreferenceKey.self, value: childProxy.size)
                        }
                    )
                    .onPreferenceChange(SizePreferenceKey.self) { size in
                        self.childSize = size
                    }
                    // Apply the computed scale factor with the desired anchor.
                    .scaleEffect(scale(for: containerSize, childSize: childSize),
                                 anchor: alignment.unitPoint)
            }
            // Ensure the content is not clipped if scaling causes overflow.
            .clipped()
        }
    }

    /// Computes the appropriate scale factor for the child based on the container and child sizes.
    private func scale(for containerSize: CGSize, childSize: CGSize) -> CGFloat {
        guard childSize.width > 0, childSize.height > 0 else { return 1 }
        let scaleX = containerSize.width / childSize.width
        let scaleY = containerSize.height / childSize.height
        return fit == .contain ? min(scaleX, scaleY) : max(scaleX, scaleY)
    }
}

/// A preference key used to capture a CGSize value (the child's size).
private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

/// An extension to map SwiftUI's Alignment values to UnitPoint values for use as a scale effect anchor.
public extension Alignment {
    var unitPoint: UnitPoint {
        switch self {
        case .top: return .top
        case .bottom: return .bottom
        case .leading: return .leading
        case .trailing: return .trailing
        case .topLeading: return .topLeading
        case .topTrailing: return .topTrailing
        case .bottomLeading: return .bottomLeading
        case .bottomTrailing: return .bottomTrailing
        default: return .center
        }
    }
}

struct FittedBox_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            Text("Container Size: 300 x 300")
                .font(.headline)
            ZStack {
                Color.gray.opacity(0.2)
                FittedBox(fit: .contain, alignment: .center) {
                    // This child has a different intrinsic size.
                    Text("Contain")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                }
            }
            .frame(width: 300, height: 300)
            .border(Color.black)

            ZStack {
                Color.gray.opacity(0.2)
                FittedBox(fit: .cover, alignment: .bottomTrailing) {
                    Text("Cover")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                }
            }
            .frame(width: 300, height: 300)
            .border(Color.black)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}

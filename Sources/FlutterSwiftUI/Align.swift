import SwiftUI

/// Alignment options that map to "start", "center", and "end".
public enum AlignAlignment {
    case start
    case center
    case end
}

/// Axis options to specify whether the alignment is horizontal or vertical.
public enum AlignAxis {
    case horizontal
    case vertical
}

/// A SwiftUI view that aligns its child content along a specific axis.
/// This component mimics the behavior of a React Flexbox-based Align component.
public struct Align<Content: View>: View {
    /// The desired alignment: .start (left/top), .center, or .end (right/bottom).
    let alignment: AlignAlignment
    
    /// The axis along which to align the content: .horizontal or .vertical.
    let axis: AlignAxis
    
    /// The child view(s) to be aligned.
    let content: Content
    
    /**
     Initializes an Align view.
     
     - Parameters:
       - alignment: The alignment for the content. Default is `.center`.
       - axis: The axis along which to align the content. Default is `.horizontal`.
       - content: A view builder that defines the content to align.
     */
    public init(alignment: AlignAlignment = .center, axis: AlignAxis = .horizontal, @ViewBuilder content: () -> Content) {
        self.alignment = alignment
        self.axis = axis
        self.content = content()
    }
    
    public var body: some View {
        Group {
            if axis == .horizontal {
                HStack {
                    switch alignment {
                    case .start:
                        content
                        Spacer()
                    case .center:
                        Spacer()
                        content
                        Spacer()
                    case .end:
                        Spacer()
                        content
                    }
                }
            } else {
                VStack {
                    switch alignment {
                    case .start:
                        content
                        Spacer()
                    case .center:
                        Spacer()
                        content
                        Spacer()
                    case .end:
                        Spacer()
                        content
                    }
                }
            }
        }
    }
}

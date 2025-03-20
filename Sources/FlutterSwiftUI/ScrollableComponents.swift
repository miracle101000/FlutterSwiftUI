import SwiftUI


/// A controller for programmatically controlling the grid’s scrolling.
/// Conforms to ObservableObject so that it can be observed by SwiftUI views.
public class ScrollController: ObservableObject {
    /// Scrolls to the top of the grid.
    var scrollToTop: (() -> Void)?
    /// Scrolls to the bottom of the grid.
    var scrollToBottom: (() -> Void)?
    /// Scrolls by the given horizontal (x) and vertical (y) amounts.
    var scrollBy: ((_ x: CGFloat, _ y: CGFloat) -> Void)?
    /// Scrolls to the given horizontal (x) and vertical (y) position.
    var scrollTo: ((_ x: CGFloat, _ y: CGFloat) -> Void)?
    /// Returns the current scroll position (top and left). (Stub: returns zeros)
    var getCurrentScrollPosition: (() -> (top: CGFloat, left: CGFloat))?
    /// Returns the maximum scroll extent (maxTop and maxLeft). (Stub: returns zeros)
    var getMaxScrollExtent: (() -> (maxTop: CGFloat, maxLeft: CGFloat))?
}

/// Specifies the direction of scrolling.
public enum ScrollDirection {
    case vertical, horizontal
}

/// Specifies the scrolling behavior. When set to `.never`, scrolling is disabled.
public enum ScrollPhysics {
    case auto, never, clamped, bouncy
}

/// A view modifier that enforces a fixed main-axis extent on grid items.
public struct MainAxisExtentModifier: ViewModifier {
    let mainAxisExtent: CGFloat?
    let scrollDirection: ScrollDirection
    
    public func body(content: Content) -> some View {
        if let extent = mainAxisExtent {
            if scrollDirection == .vertical {
                return AnyView(content.frame(height: extent))
            } else {
                return AnyView(content.frame(width: extent))
            }
        } else {
            return AnyView(content)
        }
    }
}

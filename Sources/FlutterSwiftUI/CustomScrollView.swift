import SwiftUI

/// A customizable scroll view with programmatic control and advanced layout options
public struct CustomScrollView<Content: View>: View {
    // MARK: - Configuration Properties
    @ObservedObject var controller: ScrollController
    let scrollDirection: Axis.Set
    let reverse: Bool
    let enableBounce: Bool
    let clipBehavior: Bool
    let sliverFillRemaining: Bool
    let stickyHeaders: Bool
    let onScrollPositionChange: ((CGPoint) -> Void)?
    let content: Content

    // MARK: - State Management
    @State private var scrollProxy: ScrollViewProxy?
    @State private var scrollOffset: CGPoint = .zero {
        didSet { onScrollPositionChange?(scrollOffset) }
    }
    @State private var contentSize: CGSize = .zero
    @State private var containerSize: CGSize = .zero

    // MARK: - Initialization
    public init(
        controller: ScrollController,
        scrollDirection: Axis.Set = .vertical,
        reverse: Bool = false,
        enableBounce: Bool = true,
        clipBehavior: Bool = true,
        sliverFillRemaining: Bool = false,
        stickyHeaders: Bool = true,
        onScrollPositionChange: ((CGPoint) -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.controller = controller
        self.scrollDirection = scrollDirection
        self.reverse = reverse
        self.enableBounce = enableBounce
        self.clipBehavior = clipBehavior
        self.sliverFillRemaining = sliverFillRemaining
        self.stickyHeaders = stickyHeaders
        self.onScrollPositionChange = onScrollPositionChange
        self.content = content()
    }

    public var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { proxy in
                ScrollView(scrollDirection, showsIndicators: true) {
                    scrollContent
                        .rotationEffect(reverse ? .degrees(180) : .zero)
                        .background(
                            GeometryReader { contentGeometry in
                                Color.clear
                                    .preference(
                                        key: ContentSizeKey.self,
                                        value: contentGeometry.size
                                    )
                            }
                        )
                }
                .clipped(antialiased: clipBehavior)
                .onPreferenceChange(ContentSizeKey.self) { size in
                    contentSize = size
                    containerSize = geometry.size
                }
                .onAppear {
                    scrollProxy = proxy
                    setupController()
                }
                .applyBounceBehavior()
            }
        }
        .rotationEffect(reverse ? .degrees(180) : .zero)
    }

    // MARK: - Private Helpers
    private var scrollContent: some View {
        Group {
            if scrollDirection == .vertical {
                LazyVStack(
                    spacing: 0,
                    pinnedViews: stickyHeaders ? [.sectionHeaders] : []
                ) {
                    adjustedContent
                    if sliverFillRemaining {
                        Spacer(minLength: 0)
                    }
                }
            } else {
                LazyHStack(spacing: 0) {
                    adjustedContent
                    if sliverFillRemaining {
                        Spacer(minLength: 0)
                    }
                }
            }
        }
    }

    private var adjustedContent: some View {
        Group {
            if reverse {
                content
                    .rotationEffect(.degrees(180))
            } else {
                content
            }
        }
    }

    private func setupController() {
        controller.scrollToTop = {
            withAnimation {
                scrollProxy?.scrollTo("top", anchor: .top)
            }
        }
        
        controller.scrollToBottom = {
            withAnimation {
                scrollProxy?.scrollTo("bottom", anchor: .bottom)
            }
        }
        
        controller.scrollBy = { (x: CGFloat, y: CGFloat) in
            let newOffset = CGPoint(
                x: scrollOffset.x + x,
                y: scrollOffset.y + y
            )
            withAnimation {
//                scrollProxy?.scrollTo(newOffset.hashValue, anchor: .topLeading)
            }
        }
        
        controller.scrollTo = { (x: CGFloat, y: CGFloat) in
            withAnimation {
//                scrollProxy?.scrollTo(CGPoint(x: x, y: y).hashValue, anchor: .topLeading)
            }
        }
        
        controller.getCurrentScrollPosition = {
            return (top: scrollOffset.y, left: scrollOffset.x)
        }
        
        controller.getMaxScrollExtent = {
            return (maxTop: max(contentSize.height - containerSize.height, 0),
                    maxLeft: max(contentSize.width - containerSize.width, 0))
        }
    }
}

// MARK: - Bounce Behavior Modifier
public extension View {
    @ViewBuilder
    func applyBounceBehavior() -> some View {
        if #available(iOS 16.4, *) {
            self.scrollBounceBehavior(.automatic)
        } else {
            self // Fallback for earlier versions
        }
    }
}

// MARK: - Supporting Extensions
extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

private struct ContentSizeKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

// MARK: - Preview
struct CustomScrollView_Previews: PreviewProvider {
    @StateObject static var scrollController = ScrollController()
    
    static var previews: some View {
        CustomScrollView(controller: scrollController) {
            Section(header: Text("Header")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .background(Color.blue.opacity(0.3))
                .id("top")
            ) {
                ForEach(0..<20) { index in
                    Text("Item \(index)")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.2))
                }
            }
            .id("bottom")
        }
    }
}

import SwiftUI


// MARK: - Preference Key for Scroll Offset

public struct ScrollOffsetKey: PreferenceKey {
    public static var defaultValue: CGFloat = 0
    public static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        // Use the latest offset value
        value = nextValue()
    }
}

// MARK: - NestedScrollView

/// A SwiftUI view that creates a customizable scrollable container with a header that collapses on scroll.
/// - Parameters:
///   - header: A view builder for the header content (the “sliver”). This header will shrink as the user scrolls.
///   - content: The scrollable body content.
///   - collapsedHeight: The header’s height when fully collapsed.
///   - expandedHeight: The header’s height when fully expanded.
///   - scrollDirection: The scroll axis (default is vertical).
///   - reverse: If true, the scroll direction is reversed.
///   - floatHeaderSlivers: If true, the header will overlay the content.
///   - scrollBehavior: The animation style for scrolling (default is smooth).
///   - controller: An external scroll controller for imperative scrolling.
public struct NestedScrollView<Header: View, Content: View>: View {
    let header: () -> Header
    let content: () -> Content
    let collapsedHeight: CGFloat
    let expandedHeight: CGFloat
    let scrollDirection: Axis.Set
    let reverse: Bool
    let floatHeaderSlivers: Bool
    let scrollBehavior: Animation
    @ObservedObject var controller: ScrollController

    @State private var headerHeight: CGFloat

    public init(
        scrollDirection: Axis.Set = .vertical,
        reverse: Bool = false,
        floatHeaderSlivers: Bool = false,
        scrollBehavior: Animation = .easeInOut,
        collapsedHeight: CGFloat,
        expandedHeight: CGFloat,
        controller: ScrollController,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.scrollDirection = scrollDirection
        self.reverse = reverse
        self.floatHeaderSlivers = floatHeaderSlivers
        self.scrollBehavior = scrollBehavior
        self.collapsedHeight = collapsedHeight
        self.expandedHeight = expandedHeight
        self.controller = controller
        self.header = header
        self.content = content
        _headerHeight = State(initialValue: expandedHeight)
    }

    public var body: some View {
        // Wrap in a ScrollViewReader to enable programmatic scrolling.
        ScrollView(scrollDirection, showsIndicators: true) {
            ScrollViewReader { proxy in
                ZStack(alignment: .top) {
                    // If not floating, header appears as part of the content.
                    if !floatHeaderSlivers {
                        headerSection
                    }
                    
                    VStack(spacing: 0) {
                        // Marker at the top
                        Color.clear.frame(height: 0).id("top")
                        
                        // For non-floating header, add top padding equal to headerHeight.
                        if !floatHeaderSlivers {
                            Color.clear.frame(height: headerHeight)
                        }
                        
                        // The main scrollable content.
                        content()
                        
                        // Bottom marker.
                        Color.clear.frame(height: 0).id("bottom")
                    }
                }
                .background(
                    // Use a GeometryReader to track the scroll offset.
                    GeometryReader { geo in
                        Color.clear
                            .preference(key: ScrollOffsetKey.self, value: geo.frame(in: .named("scroll")).minY)
                    }
                )
                .onPreferenceChange(ScrollOffsetKey.self) { offset in
                    // Compute the new header height based on scroll offset.
                    // For vertical scrolling, the header shrinks as the scroll offset increases.
                    let newHeight = max(collapsedHeight, expandedHeight - offset)
                    withAnimation(scrollBehavior) {
                        headerHeight = newHeight
                    }
                }
                .coordinateSpace(name: "scroll")
                .onAppear {
                    // Configure the scroll controller actions.
                    controller.scrollToTop = {
                        withAnimation(self.scrollBehavior) {
                            proxy.scrollTo("top", anchor: .top)
                        }
                    }
                    controller.scrollToBottom = {
                        withAnimation(self.scrollBehavior) {
                            proxy.scrollTo("bottom", anchor: .bottom)
                        }
                    }
                    // Note: SwiftUI does not provide direct access to the scroll offset for scrollBy or scrollTo.
                    controller.scrollBy = { x, y in
                        // Stub: Not implemented.
                    }
                    controller.scrollTo = { x, y in
                        // Stub: Not implemented.
                    }
                    controller.getCurrentScrollPosition = {
                        // Stub: SwiftUI does not expose the current scroll position.
                        return (top: 0, left: 0)
                    }
                    controller.getMaxScrollExtent = {
                        // Stub: SwiftUI does not expose maximum content offset.
                        return (maxTop: 0, maxLeft: 0)
                    }
                }
            }
        }
        // Reverse the scroll direction if needed.
        .environment(\.layoutDirection, reverse ? .rightToLeft : .leftToRight)
    }

    /// The header view, either floating on top or integrated into the scroll content.
    private var headerSection: some View {
        header()
            .frame(height: headerHeight)
            .clipped()
            .animation(scrollBehavior, value: headerHeight)
            // If floating, position the header over the content.
            .background(floatHeaderSlivers ? Color.clear : Color.clear)
    }
}

// MARK: - Example Usage

struct NestedScrollView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a ScrollController for external control.
        let scrollController = ScrollController()
        
        return VStack {
            HStack {
                Button("Scroll to Top") {
                    scrollController.scrollToTop?()
                }
                Button("Scroll to Bottom") {
                    scrollController.scrollToBottom?()
                }
            }
            .padding()
            
            NestedScrollView(
                scrollDirection: .vertical,
                reverse: false,
                floatHeaderSlivers: true,
                collapsedHeight: 50,
                expandedHeight: 200,
                controller: scrollController,
                header: {
                    // Header content (can be any view)
                    ZStack {
                        Color.blue
                        Text("Collapsible Header")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                },
                content: {
                    // Body content: a list of items.
                    VStack(spacing: 10) {
                        ForEach(0..<30) { index in
                            Text("Item \(index + 1)")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                }
            )
            .border(Color.gray)
        }
        .previewLayout(.sizeThatFits)
    }
}

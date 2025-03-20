import SwiftUI


// MARK: - ListView

/// A SwiftUI ListView that arranges its children in a lazy list layout with programmatic scroll control.
public struct ListView<Content: View>: View {
    let content: () -> Content
    let scrollDirection: ScrollDirection
    let physics: ScrollPhysics
    let reverse: Bool
    @ObservedObject var scrollController: ScrollController
    
    public init(
        scrollDirection: ScrollDirection = .vertical,
        physics: ScrollPhysics = .clamped,
        reverse: Bool = false,
        scrollController: ScrollController,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.scrollDirection = scrollDirection
        self.physics = physics
        self.reverse = reverse
        self.scrollController = scrollController
        self.content = content
    }
    
    public var body: some View {
        // Choose a vertical or horizontal ScrollView based on the provided direction.
        ScrollView(scrollDirection == .vertical ? .vertical : .horizontal, showsIndicators: true) {
            ScrollViewReader { proxy in
                Group {
                    if scrollDirection == .vertical {
                        verticalContent(with: proxy)
                    } else {
                        horizontalContent(with: proxy)
                    }
                }
                .onAppear {
                    // Set up the scroll controller actions using the markers.
                    scrollController.scrollToTop = {
                        withAnimation {
                            proxy.scrollTo(reverse ? "bottom" : "top", anchor: .top)
                        }
                    }
                    scrollController.scrollToBottom = {
                        withAnimation {
                            proxy.scrollTo(reverse ? "top" : "bottom", anchor: .bottom)
                        }
                    }
                    scrollController.scrollBy = { x, y in
                        // Stub implementation: SwiftUI’s ScrollViewReader does not directly support offset-based scrolling.
                    }
                    scrollController.scrollTo = { x, y in
                        // Stub implementation: SwiftUI does not support direct coordinate scrolling.
                    }
                    scrollController.getCurrentScrollPosition = {
                        // Stub implementation: SwiftUI does not expose the current offset.
                        return (top: 0, left: 0)
                    }
                    scrollController.getMaxScrollExtent = {
                        // Stub implementation: SwiftUI does not expose maximum content offset.
                        return (maxTop: 0, maxLeft: 0)
                    }
                }
            }
        }
        .disabled(physics == .never)
    }
    
    // MARK: - Vertical Content
    
    /// Builds the vertical list content using a LazyVStack. If reverse is true, the list is visually flipped.
    @ViewBuilder
    private func verticalContent(with proxy: ScrollViewProxy) -> some View {
        if reverse {
            LazyVStack(spacing: 0) {
                // In reversed mode, the top marker is placed at the bottom.
                Color.clear.frame(height: 1).id("bottom")
                content()
                    .scaleEffect(y: -1) // Flip individual child views.
                Color.clear.frame(height: 1).id("top")
            }
            .scaleEffect(y: -1) // Flip the entire LazyVStack.
        } else {
            LazyVStack(spacing: 0) {
                Color.clear.frame(height: 1).id("top")
                content()
                Color.clear.frame(height: 1).id("bottom")
            }
        }
    }
    
    // MARK: - Horizontal Content
    
    /// Builds the horizontal list content using a LazyHStack.
    @ViewBuilder
    private func horizontalContent(with proxy: ScrollViewProxy) -> some View {
        LazyHStack(spacing: 0) {
            Color.clear.frame(width: 1).id("top")
            content()
            Color.clear.frame(width: 1).id("bottom")
        }
        .environment(\.layoutDirection, reverse ? .rightToLeft : .leftToRight)
    }
}

// MARK: - Preview

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 30) {
            Text("Vertical List")
                .font(.headline)
            ListView(
                scrollDirection: .vertical,
                physics: .clamped,
                reverse: false,
                scrollController: ScrollController()
            ) {
                ForEach(0..<20, id: \.self) { index in
                    Text("Item \(index)")
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(8)
                }
            }
            .frame(height: 300)
            .border(Color.gray)
            
            Text("Horizontal List (Reversed)")
                .font(.headline)
            ListView(
                scrollDirection: .horizontal,
                physics: .bouncy,
                reverse: true,
                scrollController: ScrollController()
            ) {
                ForEach(0..<10, id: \.self) { index in
                    Text("Item \(index)")
                        .padding()
                        .frame(width: 100, height: 100)
                        .background(Color.green.opacity(0.3))
                        .cornerRadius(8)
                }
            }
            .frame(height: 140)
            .border(Color.gray)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}

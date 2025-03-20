import SwiftUI



// MARK: - ListViewBuilder

/// A SwiftUI view that builds a list of items using a builder function. It uses lazy stacks
/// for efficient rendering and allows programmatic scrolling via a scroll controller.
public struct ListViewBuilder<Content: View>: View {
    let itemCount: Int
    let itemBuilder: (Int) -> Content
    let scrollDirection: ScrollDirection
    let physics: ScrollPhysics
    let reverse: Bool
    @ObservedObject var scrollController: ScrollController
    
    public init(
        itemCount: Int,
        scrollDirection: ScrollDirection = .vertical,
        physics: ScrollPhysics = .clamped,
        reverse: Bool = false,
        scrollController: ScrollController,
        @ViewBuilder itemBuilder: @escaping (Int) -> Content
    ) {
        self.itemCount = itemCount
        self.itemBuilder = itemBuilder
        self.scrollDirection = scrollDirection
        self.physics = physics
        self.reverse = reverse
        self.scrollController = scrollController
    }
    
    public var body: some View {
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
                    // Configure scroll controller closures to scroll to markers.
                    scrollController.scrollToTop = {
                        withAnimation {
                            // In reversed mode, the "bottom" marker is at the top.
                            proxy.scrollTo(reverse ? "bottom" : "top", anchor: .top)
                        }
                    }
                    scrollController.scrollToBottom = {
                        withAnimation {
                            proxy.scrollTo(reverse ? "top" : "bottom", anchor: .bottom)
                        }
                    }
                    scrollController.scrollBy = { x, y in
                        // Stub: SwiftUI's ScrollViewReader does not support offset-based scrolling.
                    }
                    scrollController.scrollTo = { x, y in
                        // Stub: Direct coordinate scrolling is not available in native SwiftUI.
                    }
                    scrollController.getCurrentScrollPosition = {
                        // Stub: Current offset is not exposed.
                        return (top: 0, left: 0)
                    }
                    scrollController.getMaxScrollExtent = {
                        // Stub: Maximum content offset is not exposed.
                        return (maxTop: 0, maxLeft: 0)
                    }
                }
            }
        }
        .disabled(physics == .never)
    }
    
    // MARK: - Vertical Content
    
    /// Builds vertical list content using a LazyVStack.
    @ViewBuilder
    private func verticalContent(with proxy: ScrollViewProxy) -> some View {
        if reverse {
            LazyVStack(spacing: 0) {
                // Bottom marker acts as the top in reversed mode.
                Color.clear.frame(height: 1).id("bottom")
                // Reverse the order of items.
                ForEach((0..<itemCount).reversed(), id: \.self) { index in
                    itemBuilder(index)
                }
                // Top marker acts as the bottom.
                Color.clear.frame(height: 1).id("top")
            }
        } else {
            LazyVStack(spacing: 0) {
                Color.clear.frame(height: 1).id("top")
                ForEach(0..<itemCount, id: \.self) { index in
                    itemBuilder(index)
                }
                Color.clear.frame(height: 1).id("bottom")
            }
        }
    }
    
    // MARK: - Horizontal Content
    
    /// Builds horizontal list content using a LazyHStack.
    @ViewBuilder
    private func horizontalContent(with proxy: ScrollViewProxy) -> some View {
        if reverse {
            LazyHStack(spacing: 0) {
                Color.clear.frame(width: 1).id("bottom")
                ForEach((0..<itemCount).reversed(), id: \.self) { index in
                    itemBuilder(index)
                }
                Color.clear.frame(width: 1).id("top")
            }
            .environment(\.layoutDirection, .rightToLeft)
        } else {
            LazyHStack(spacing: 0) {
                Color.clear.frame(width: 1).id("top")
                ForEach(0..<itemCount, id: \.self) { index in
                    itemBuilder(index)
                }
                Color.clear.frame(width: 1).id("bottom")
            }
            .environment(\.layoutDirection, .leftToRight)
        }
    }
}

// MARK: - Preview

struct ListViewBuilder_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 30) {
            Text("Vertical List")
                .font(.headline)
            ListViewBuilder(
                itemCount: 20,
                scrollDirection: .vertical,
                physics: .clamped,
                reverse: false,
                scrollController: ScrollController()
            ) { index in
                Text("Item \(index)")
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(8)
            }
            .frame(height: 300)
            .border(Color.gray)
            
            Text("Horizontal List (Reversed)")
                .font(.headline)
            ListViewBuilder(
                itemCount: 10,
                scrollDirection: .horizontal,
                physics: .bouncy,
                reverse: true,
                scrollController: ScrollController()
            ) { index in
                Text("Item \(index)")
                    .padding()
                    .frame(width: 100, height: 100)
                    .background(Color.green.opacity(0.3))
                    .cornerRadius(8)
            }
            .frame(height: 140)
            .border(Color.gray)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}

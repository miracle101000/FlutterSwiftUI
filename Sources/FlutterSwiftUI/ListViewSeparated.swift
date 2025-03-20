import SwiftUI


// MARK: - ListViewSeparated

/// A SwiftUI view that builds a list of items with separators between them.
/// It uses lazy stacks for efficient loading, supports reverse ordering,
/// and exposes scroll control via a ScrollController.
public struct ListViewSeparated<ItemContent: View, SeparatorContent: View>: View {
    let itemCount: Int
    let itemBuilder: (Int) -> ItemContent
    let separatorBuilder: () -> SeparatorContent
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
        @ViewBuilder itemBuilder: @escaping (Int) -> ItemContent,
        @ViewBuilder separatorBuilder: @escaping () -> SeparatorContent
    ) {
        self.itemCount = itemCount
        self.scrollDirection = scrollDirection
        self.physics = physics
        self.reverse = reverse
        self.scrollController = scrollController
        self.itemBuilder = itemBuilder
        self.separatorBuilder = separatorBuilder
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
                    // Configure the scroll controller actions using the markers.
                    scrollController.scrollToTop = {
                        withAnimation {
                            // In reverse mode, the top marker is actually at "bottom".
                            proxy.scrollTo(reverse ? "bottom" : "top", anchor: .top)
                        }
                    }
                    scrollController.scrollToBottom = {
                        withAnimation {
                            proxy.scrollTo(reverse ? "top" : "bottom", anchor: .bottom)
                        }
                    }
                    scrollController.scrollBy = { x, y in
                        // Stub implementation: SwiftUI does not support offset-based scrolling directly.
                    }
                    scrollController.scrollTo = { x, y in
                        // Stub implementation.
                    }
                    scrollController.getCurrentScrollPosition = {
                        // Stub implementation.
                        return (top: 0, left: 0)
                    }
                    scrollController.getMaxScrollExtent = {
                        // Stub implementation.
                        return (maxTop: 0, maxLeft: 0)
                    }
                }
            }
        }
        .disabled(physics == .never)
    }
    
    // MARK: - Vertical Content
    
    /// Builds vertical list content with separators using LazyVStack.
    @ViewBuilder
    private func verticalContent(with proxy: ScrollViewProxy) -> some View {
        if reverse {
            LazyVStack(spacing: 0) {
                // Bottom marker (appears as the top when reversed)
                Color.clear.frame(height: 1).id("bottom")
                // Iterate in reverse order.
                ForEach((0..<itemCount).reversed(), id: \.self) { index in
                    itemBuilder(index)
                    if index != 0 { // Do not add a separator after the last (first in reversed order)
                        separatorBuilder()
                    }
                }
                // Top marker (appears as the bottom when reversed)
                Color.clear.frame(height: 1).id("top")
            }
        } else {
            LazyVStack(spacing: 0) {
                Color.clear.frame(height: 1).id("top")
                ForEach(0..<itemCount, id: \.self) { index in
                    itemBuilder(index)
                    if index < itemCount - 1 {
                        separatorBuilder()
                    }
                }
                Color.clear.frame(height: 1).id("bottom")
            }
        }
    }
    
    // MARK: - Horizontal Content
    
    /// Builds horizontal list content with separators using LazyHStack.
    @ViewBuilder
    private func horizontalContent(with proxy: ScrollViewProxy) -> some View {
        if reverse {
            LazyHStack(spacing: 0) {
                Color.clear.frame(width: 1).id("bottom")
                ForEach((0..<itemCount).reversed(), id: \.self) { index in
                    itemBuilder(index)
                    if index != 0 {
                        separatorBuilder()
                    }
                }
                Color.clear.frame(width: 1).id("top")
            }
            .environment(\.layoutDirection, .rightToLeft)
        } else {
            LazyHStack(spacing: 0) {
                Color.clear.frame(width: 1).id("top")
                ForEach(0..<itemCount, id: \.self) { index in
                    itemBuilder(index)
                    if index < itemCount - 1 {
                        separatorBuilder()
                    }
                }
                Color.clear.frame(width: 1).id("bottom")
            }
            .environment(\.layoutDirection, .leftToRight)
        }
    }
}

// MARK: - Preview

struct ListViewSeparated_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 30) {
            Text("Vertical List with Separators")
                .font(.headline)
            ListViewSeparated(
                itemCount: 5,
                scrollDirection: .vertical,
                physics: .clamped,
                reverse: false,
                scrollController: ScrollController(),
                itemBuilder: { index in
                    Text("Item \(index + 1)")
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(8)
                },
                separatorBuilder: {
                    Divider()
                }
            )
            .frame(height: 300)
            .border(Color.gray)
            
            Text("Horizontal List with Separators (Reversed)")
                .font(.headline)
            ListViewSeparated(
                itemCount: 5,
                scrollDirection: .horizontal,
                physics: .bouncy,
                reverse: true,
                scrollController: ScrollController(),
                itemBuilder: { index in
                    Text("Item \(index + 1)")
                        .padding()
                        .frame(width: 100, height: 100)
                        .background(Color.green.opacity(0.3))
                        .cornerRadius(8)
                },
                separatorBuilder: {
                    Divider().frame(width: 1)
                }
            )
            .frame(height: 140)
            .border(Color.gray)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}

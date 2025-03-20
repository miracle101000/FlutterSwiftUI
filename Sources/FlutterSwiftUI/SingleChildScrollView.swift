import SwiftUI

// MARK: - Preference Key

private struct ContentSizeKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

// MARK: - SingleChildScrollView

/// A customizable scroll view with programmatic control and physics settings
public struct SingleChildScrollView<Content: View>: View {
    // MARK: - Properties
    @ObservedObject var controller: ScrollController
    let vertical: Bool
    let horizontal: Bool
    let scrollPhysics: ScrollPhysics
    let content: Content

    // MARK: - State Management
    @State private var scrollProxy: ScrollViewProxy?
    @State private var scrollOffset: CGPoint = .zero
    @State private var contentSize: CGSize = .zero
    @State private var containerSize: CGSize = .zero

    // MARK: - Initialization
    public init(
        controller: ScrollController,
        vertical: Bool = true,
        horizontal: Bool = false,
        scrollPhysics: ScrollPhysics = .clamped,
        @ViewBuilder content: () -> Content
    ) {
        self.controller = controller
        self.vertical = vertical
        self.horizontal = horizontal
        self.scrollPhysics = scrollPhysics
        self.content = content()
    }

    // MARK: - Body
    public var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { proxy in
                ScrollView(
                    vertical ? .vertical : .horizontal,
                    showsIndicators: true
                ) {
                    content
                        .background(
                            GeometryReader { contentGeometry in
                                Color.clear.preference(key: ContentSizeKey.self, value: contentGeometry.size)
                            }
                        )
                }
                .onPreferenceChange(ContentSizeKey.self) { size in
                    contentSize = size
                    containerSize = geometry.size
                }
                .onAppear {
                    scrollProxy = proxy
                    setupController()
                }
                .applyBounceBehavior()
                .disabled(scrollPhysics == .never) // Disable scrolling if set to `.never`
            }
        }
    }

    // MARK: - Private Helpers
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
            let newOffset = CGPoint(x: scrollOffset.x + x, y: scrollOffset.y + y)
            withAnimation {
                // Note: SwiftUI's ScrollViewReader does not support direct scrolling to a CGPoint.
                // This is a stub implementation.
            }
        }

        controller.scrollTo = { (x: CGFloat, y: CGFloat) in
            withAnimation {
                // Stub: Direct scrolling to a specific CGPoint is not directly supported.
            }
        }

        controller.getCurrentScrollPosition = {
            (top: scrollOffset.y, left: scrollOffset.x)
        }

        controller.getMaxScrollExtent = {
            (maxTop: max(contentSize.height - containerSize.height, 0),
             maxLeft: max(contentSize.width - containerSize.width, 0))
        }
    }
}


// MARK: - Preview
struct SingleChildScrollView_Previews: PreviewProvider {
    @StateObject static var scrollController = ScrollController()

    static var previews: some View {
        SingleChildScrollView(
            controller: scrollController,
            vertical: true,
            scrollPhysics: .bouncy
        ) {
            VStack {
                ForEach(0..<20) { index in
                    Text("Item \(index)")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(8)
                }
            }
        }
        .frame(height: 300)
        .border(Color.gray)
        .previewLayout(.sizeThatFits)
    }
}

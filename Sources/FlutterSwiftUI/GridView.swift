import SwiftUI



/// A flexible grid view that arranges its children into a grid layout with programmatic scroll control.
public struct GridView<Content: View>: View {
    let content: () -> Content
    let scrollDirection: ScrollDirection
    let physics: ScrollPhysics
    let crossAxisCount: Int
    let mainAxisExtent: CGFloat?
    let spacing: CGFloat
    @ObservedObject var scrollController: ScrollController
    
    public init(
        scrollDirection: ScrollDirection = .vertical,
        physics: ScrollPhysics = .clamped,
        crossAxisCount: Int,
        mainAxisExtent: CGFloat? = nil,
        spacing: CGFloat = 0,
        scrollController: ScrollController,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.scrollDirection = scrollDirection
        self.physics = physics
        self.crossAxisCount = crossAxisCount
        self.mainAxisExtent = mainAxisExtent
        self.spacing = spacing
        self.scrollController = scrollController
        self.content = content
    }
    
    public var body: some View {
        ScrollView(scrollDirection == .vertical ? .vertical : .horizontal, showsIndicators: true) {
            ScrollViewReader { proxy in
                Group {
                    if scrollDirection == .vertical {
                        LazyVGrid(
                            columns: Array(repeating: GridItem(.flexible(), spacing: spacing), count: crossAxisCount),
                            spacing: spacing
                        ) {
                            // Top marker for scrolling to top.
                            Color.clear
                                .frame(height: 1)
                                .id("top")
                            // Grid items with fixed main axis extent if provided.
                            content()
                                .modifier(MainAxisExtentModifier(mainAxisExtent: mainAxisExtent, scrollDirection: scrollDirection))
                            // Bottom marker for scrolling to bottom.
                            Color.clear
                                .frame(height: 1)
                                .id("bottom")
                        }
                        .padding(.horizontal, spacing)
                    } else {
                        LazyHGrid(
                            rows: Array(repeating: GridItem(.flexible(), spacing: spacing), count: crossAxisCount),
                            spacing: spacing
                        ) {
                            Color.clear
                                .frame(width: 1)
                                .id("top")
                            content()
                                .modifier(MainAxisExtentModifier(mainAxisExtent: mainAxisExtent, scrollDirection: scrollDirection))
                            Color.clear
                                .frame(width: 1)
                                .id("bottom")
                        }
                        .padding(.vertical, spacing)
                    }
                }
                .onAppear {
                    scrollController.scrollToTop = {
                        withAnimation {
                            proxy.scrollTo("top", anchor: .top)
                        }
                    }
                    scrollController.scrollToBottom = {
                        withAnimation {
                            proxy.scrollTo("bottom", anchor: .bottom)
                        }
                    }
                    scrollController.scrollBy = { (x: CGFloat, y: CGFloat) in
                        // Stub implementation (SwiftUI does not offer a direct API)
                    }
                    scrollController.scrollTo = { (x: CGFloat, y: CGFloat) in
                        // Stub implementation (SwiftUI does not offer a direct API)
                    }
                    scrollController.getCurrentScrollPosition = {
                        return (top: 0, left: 0)
                    }
                    scrollController.getMaxScrollExtent = {
                        return (maxTop: 0, maxLeft: 0)
                    }
                }
            }
        }
        .disabled(physics == .never)
    }
}



struct GridView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Vertical Grid (3 columns)")
                .font(.headline)
            GridView(
                scrollDirection: .vertical,
                physics: .clamped,
                crossAxisCount: 3,
                mainAxisExtent: 100,
                spacing: 20,
                scrollController: ScrollController()
            ) {
                ForEach(0..<12, id: \.self) { index in
                    Text("Item \(index)")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(hue: Double(index)/12.0, saturation: 0.6, brightness: 0.9))
                }
            }
            .frame(height: 400)
            .border(Color.gray)
            
            Text("Horizontal Grid (4 rows)")
                .font(.headline)
            GridView(
                scrollDirection: .horizontal,
                physics: .clamped,
                crossAxisCount: 4,
                mainAxisExtent: 200,
                spacing: 10,
                scrollController: ScrollController()
            ) {
                ForEach(0..<8, id: \.self) { index in
                    Text("Item \(index)")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(hue: Double(index)/8.0, saturation: 0.6, brightness: 0.9))
                }
            }
            .frame(height: 220)
            .border(Color.gray)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}

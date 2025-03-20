
import SwiftUI

// MARK: - GridViewBuilder

/**
 A customizable grid layout component that dynamically generates grid items based on
 an item builder function and a total item count.
 
 This view supports:
 - Vertical or horizontal scrolling (using LazyVGrid or LazyHGrid).
 - Configurable number of columns (or rows) via `crossAxisCount`.
 - Fixed item size on the main axis via `mainAxisExtent`.
 - Spacing between items.
 - Programmatic scroll control via a `GridScrollController`.
 
 Example usage:
 
 ```swift
 struct ContentView: View {
     @StateObject var scrollController = GridScrollController()
     
     var body: some View {
         VStack {
             Button("Scroll to Top") {
                 scrollController.scrollToTop?()
             }
             GridViewBuilder(
                 itemCount: 10,
                 itemBuilder: { index in
                     Text("Item \(index + 1)")
                         .frame(maxWidth: .infinity, maxHeight: .infinity)
                         .background(Color.red.opacity(0.3))
                 },
                 scrollDirection: .vertical,
                 physics: .auto,
                 crossAxisCount: 3,
                 mainAxisExtent: 100,
                 spacing: 10,
                 scrollController: scrollController
             )
             .frame(height: 400)
             .border(Color.gray)
         }
         .padding()
     }
 }
 ```
 
 - Parameters:
    - `itemCount`: Total number of items in the grid.
    - `itemBuilder`: A closure that returns a view for a given item index.
    - `scrollDirection`: The scrolling direction (`.vertical` or `.horizontal`).
    - `physics`: Controls scrolling behavior. If set to `.never`, scrolling is disabled.
    - `crossAxisCount`: The number of columns (for vertical) or rows (for horizontal).
    - `mainAxisExtent`: Fixed height (vertical) or width (horizontal) for each grid item.
    - `spacing`: Spacing between grid items.
    - `scrollController`: A reference to a controller for programmatically controlling scroll.
 */
public struct GridViewBuilder<Content: View>: View {
    let itemCount: Int
    let itemBuilder: (Int) -> Content
    let scrollDirection: ScrollDirection
    let physics: ScrollPhysics
    let crossAxisCount: Int
    let mainAxisExtent: CGFloat?
    let spacing: CGFloat
    @ObservedObject var scrollController: ScrollController

    public init(
        itemCount: Int,
        itemBuilder: @escaping (Int) -> Content,
        scrollDirection: ScrollDirection = .vertical,
        physics: ScrollPhysics = .clamped,
        crossAxisCount: Int,
        mainAxisExtent: CGFloat? = nil,
        spacing: CGFloat = 0,
        scrollController: ScrollController
    ) {
        self.itemCount = itemCount
        self.itemBuilder = itemBuilder
        self.scrollDirection = scrollDirection
        self.physics = physics
        self.crossAxisCount = crossAxisCount
        self.mainAxisExtent = mainAxisExtent
        self.spacing = spacing
        self.scrollController = scrollController
    }

    public var body: some View {
        // Use a ScrollView with appropriate axis.
        ScrollView(
            scrollDirection == .vertical ? .vertical : .horizontal,
            showsIndicators: true
        ) {
            // ScrollViewReader provides programmatic scrolling.
            ScrollViewReader { proxy in
                Group {
                    if scrollDirection == .vertical {
                        // Create a vertical grid.
                        LazyVGrid(
                            columns: Array(
                                repeating: GridItem(.flexible(), spacing: spacing),
                                count: crossAxisCount
                            ),
                            spacing: spacing
                        ) {
                            // A top marker for scrolling.
                            Color.clear
                                .frame(height: 1)
                                .id("top")
                            
                            // Dynamically generate grid items.
                            ForEach(0..<itemCount, id: \.self) { index in
                                itemBuilder(index)
                                    .modifier(
                                        MainAxisExtentModifier(
                                            mainAxisExtent: mainAxisExtent,
                                            scrollDirection: scrollDirection
                                        )
                                    )
                            }
                            
                            // A bottom marker for scrolling.
                            Color.clear
                                .frame(height: 1)
                                .id("bottom")
                        }
                        .padding(.horizontal, spacing)
                    } else {
                        // Create a horizontal grid.
                        LazyHGrid(
                            rows: Array(
                                repeating: GridItem(.flexible(), spacing: spacing),
                                count: crossAxisCount
                            ),
                            spacing: spacing
                        ) {
                            Color.clear
                                .frame(width: 1)
                                .id("top")
                            
                            ForEach(0..<itemCount, id: \.self) { index in
                                itemBuilder(index)
                                    .modifier(
                                        MainAxisExtentModifier(
                                            mainAxisExtent: mainAxisExtent,
                                            scrollDirection: scrollDirection
                                        )
                                    )
                            }
                            
                            Color.clear
                                .frame(width: 1)
                                .id("bottom")
                        }
                        .padding(.vertical, spacing)
                    }
                }
                .onAppear {
                    // Expose scroll control methods via the controller.
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
                        // Stub: SwiftUI does not expose direct APIs for relative scrolling.
                    }
                    scrollController.scrollTo = { (x: CGFloat, y: CGFloat) in
                        // Stub: SwiftUI does not expose direct APIs for absolute scrolling.
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
        // Disable scrolling if physics is set to `.never`
        .disabled(physics == .never)
    }
}

// MARK: - Previews

struct GridViewBuilder_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 30) {
            Text("Vertical Grid (3 columns)")
                .font(.headline)
            
            GridViewBuilder(
                itemCount: 10,
                itemBuilder: { index in
                    Text("Item \(index + 1)")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.red.opacity(0.3))
                },
                scrollDirection: .vertical,
                physics: .auto,
                crossAxisCount: 3,
                mainAxisExtent: 100,
                spacing: 10,
                scrollController: ScrollController()
            )
            .frame(height: 400)
            .border(Color.gray)
            
            Text("Horizontal Grid (2 rows)")
                .font(.headline)
            
            GridViewBuilder(
                itemCount: 5,
                itemBuilder: { index in
                    Text("Horizontal Item \(index + 1)")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.blue.opacity(0.3))
                },
                scrollDirection: .horizontal,
                physics: .auto,
                crossAxisCount: 2,
                mainAxisExtent: 200,
                spacing: 15,
                scrollController: ScrollController()
            )
            .frame(height: 220)
            .border(Color.gray)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}


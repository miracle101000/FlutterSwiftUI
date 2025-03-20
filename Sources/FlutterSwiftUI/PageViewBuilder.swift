import SwiftUI

/// A SwiftUI view that builds a paged view by dynamically creating pages using an item builder.
/// It supports external control via a `PageController`, reverse ordering, and invokes a callback when the page changes.
///
/// Example usage:
/// ```swift
/// let controller = PageController()
/// PageViewBuilder(
///     count: 5,
///     scrollDirection: .horizontal,
///     reverse: false,
///     pageSnapping: true,
///     onPageChanged: { newPage in print("Page changed: \(newPage)") },
///     controller: controller,
///     padEnds: true
/// ) { index in
///     Text("Page \(index + 1)")
///         .frame(maxWidth: .infinity, maxHeight: .infinity)
///         .background(index % 2 == 0 ? Color.red : Color.blue)
/// }
/// .frame(height: 300)
/// ```
///
/// - Parameters:
///   - count: The number of pages to display.
///   - itemBuilder: A closure that builds the content for each page based on its index.
///   - scrollDirection: The direction of scrolling (horizontal or vertical). Defaults to horizontal.
///   - reverse: If true, the pages are displayed in reverse order. Defaults to false.
///   - pageSnapping: Whether page snapping is enabled. Defaults to true.
///   - onPageChanged: An optional callback invoked whenever the current page changes.
///   - controller: A `PageController` instance for external control of the page view.
///   - padEnds: If true, applies padding at the ends of the view. Defaults to true.
public struct PageViewBuilder<Item: View>: View {
    let count: Int
    let itemBuilder: (Int) -> Item
    let scrollDirection: Axis.Set
    let reverse: Bool
    let pageSnapping: Bool
    let onPageChanged: ((Int) -> Void)?
    let padEnds: Bool
    @ObservedObject var controller: PageController
    
    // Internal selection state for the TabView.
    @State private var selection: Int = 0
    
    /// Creates a new PageViewBuilder.
    public init(
        count: Int,
        scrollDirection: Axis.Set = .horizontal,
        reverse: Bool = false,
        pageSnapping: Bool = true,
        onPageChanged: ((Int) -> Void)? = nil,
        controller: PageController,
        padEnds: Bool = true,
        @ViewBuilder itemBuilder: @escaping (Int) -> Item
    ) {
        self.count = count
        self.itemBuilder = itemBuilder
        self.scrollDirection = scrollDirection
        self.reverse = reverse
        self.pageSnapping = pageSnapping
        self.onPageChanged = onPageChanged
        self.controller = controller
        self.padEnds = padEnds
        _selection = State(initialValue: controller.currentPage)
    }
    
    public var body: some View {
        TabView(selection: $selection) {
            ForEach(0..<count, id: \.self) { index in
                // Adjust index if reverse is enabled.
                let pageIndex = reverse ? (count - 1 - index) : index
                LazyView { itemBuilder(pageIndex) }
                    .tag(pageIndex)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(padEnds ? .horizontal : [])
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        // For vertical scrolling, rotate the TabView (a common workaround).
        .rotationEffect(scrollDirection == .vertical ? Angle(degrees: 90) : Angle(degrees: 0))
        .onChange(of: selection) { newSelection in
            controller.setPage(newSelection)
            onPageChanged?(newSelection)
        }
        .onReceive(controller.$currentPage) { newPage in
            if newPage != selection {
                withAnimation {
                    selection = newPage
                }
            }
        }
    }
}

/// A preview for the PageViewBuilder.
struct PageViewBuilder_Previews: PreviewProvider {
    static var previews: some View {
        let controller = PageController()
        VStack {
            HStack {
                Button("Previous Page") {
                    controller.previousPage()
                }
                Button("Next Page") {
                    controller.nextPage(totalPages: 5)
                }
            }
            .padding()
            
            PageViewBuilder(
                count: 5,
                scrollDirection: .horizontal,
                reverse: false,
                pageSnapping: true,
                onPageChanged: { page in
                    print("Current page: \(page)")
                },
                controller: controller,
                padEnds: true
            ) { index in
                Text("Page \(index + 1)")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(index % 2 == 0 ? Color.red : Color.blue)
            }
            .frame(height: 300)
            .border(Color.gray)
        }
        .previewLayout(.sizeThatFits)
    }
}

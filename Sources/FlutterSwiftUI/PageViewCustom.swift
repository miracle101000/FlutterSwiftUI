import SwiftUI

/// A SwiftUI view that builds a paged view by dynamically creating pages using an item builder.
/// It supports external control via a `PageController`, reverse ordering, and invokes a callback when the page changes.
///
/// Example usage:
/// ```swift
/// let controller = PageController()
/// PageViewCustom(
///     count: 5,
///     scrollDirection: .horizontal,
///     reverse: false,
///     pageSnapping: true,
///     onPageChanged: { page in print("Page changed: \(page)") },
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
///   - scrollDirection: The direction in which pages scroll. Defaults to `.horizontal`.
///   - reverse: If true, pages are displayed in reverse order. Defaults to `false`.
///   - pageSnapping: Whether pages should snap into place when scrolling. Defaults to `true`.
///   - onPageChanged: A callback triggered when the current page changes.
///   - controller: A `PageController` instance for external control.
///   - padEnds: If true, applies padding at the ends of the view. Defaults to `true`.
///   - itemBuilder: A view builder that creates the content for each page given its index.
public struct PageViewCustom<Content: View>: View {
    let count: Int
    let scrollDirection: Axis.Set
    let reverse: Bool
    let pageSnapping: Bool
    let onPageChanged: ((Int) -> Void)?
    let padEnds: Bool
    @ObservedObject var controller: PageController
    let itemBuilder: (Int) -> Content
    
    // Internal selection state for the TabView.
    @State private var selection: Int = 0
    
    /// Creates a new `PageViewCustom`.
    public init(
        count: Int,
        scrollDirection: Axis.Set = .horizontal,
        reverse: Bool = false,
        pageSnapping: Bool = true,
        onPageChanged: ((Int) -> Void)? = nil,
        controller: PageController,
        padEnds: Bool = true,
        @ViewBuilder itemBuilder: @escaping (Int) -> Content
    ) {
        self.count = count
        self.scrollDirection = scrollDirection
        self.reverse = reverse
        self.pageSnapping = pageSnapping
        self.onPageChanged = onPageChanged
        self.controller = controller
        self.padEnds = padEnds
        self.itemBuilder = itemBuilder
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
        .onChange(of: selection) { newValue in
            controller.setPage(newValue)
            onPageChanged?(newValue)
        }
        .onReceive(controller.$currentPage) { newValue in
            if newValue != selection {
                withAnimation {
                    selection = newValue
                }
            }
        }
    }
}

/// A preview for the `PageViewCustom` view.
struct PageViewCustom_Previews: PreviewProvider {
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
            
            PageViewCustom(
                count: 5,
                scrollDirection: .horizontal,
                reverse: false,
                pageSnapping: true,
                onPageChanged: { page in print("Current Page: \(page)") },
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

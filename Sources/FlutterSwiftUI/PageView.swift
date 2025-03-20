import SwiftUI

/// A view that displays pages that the user can swipe between. The view supports
/// external control via a PageController, and notifies when the page changes.
public struct PageView: View {
    /// The scroll direction for paging. Currently, only horizontal paging is fully supported.
    let scrollDirection: Axis.Set
    /// Whether page snapping is enabled.
    let pageSnapping: Bool
    /// Callback when the page changes.
    let onPageChanged: ((Int) -> Void)?
    /// If true, the order of pages is reversed.
    let reverse: Bool
    /// Whether to add padding to the ends.
    let padEnds: Bool
    /// The pages to display.
    let pages: [AnyView]
    
    /// The external controller for programmatic page control.
    @ObservedObject var controller: PageController
    /// Internal state tracking the current page.
    @State private var selection: Int = 0
    
    /// Creates a new PageView.
    ///
    /// - Parameters:
    ///   - scrollDirection: The direction of paging (default is horizontal).
    ///   - pageSnapping: Whether page snapping is enabled (default is true).
    ///   - reverse: If true, reverses the order of pages (default is false).
    ///   - padEnds: If true, applies padding at the ends (default is true).
    ///   - controller: A PageController for external control.
    ///   - onPageChanged: A callback triggered when the page changes.
    ///   - pages: An array of pages wrapped in AnyView.
    public init(
        scrollDirection: Axis.Set = .horizontal,
        pageSnapping: Bool = true,
        reverse: Bool = false,
        padEnds: Bool = true,
        controller: PageController,
        onPageChanged: ((Int) -> Void)? = nil,
        pages: [AnyView]
    ) {
        self.scrollDirection = scrollDirection
        self.pageSnapping = pageSnapping
        self.reverse = reverse
        self.padEnds = padEnds
        self.controller = controller
        self.onPageChanged = onPageChanged
        // Reverse the pages if needed.
        self.pages = reverse ? pages.reversed() : pages
        _selection = State(initialValue: controller.currentPage)
    }
    
    public var body: some View {
        TabView(selection: $selection) {
            ForEach(0..<pages.count, id: \.self) { index in
                // Wrap each page in LazyView so that its content is built on demand.
                LazyView { pages[index] }
                    .tag(index)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(padEnds ? .horizontal : [])
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        // For vertical paging, rotate the TabView (this is a common workaround).
        .rotationEffect(scrollDirection == .vertical ? Angle(degrees: 90) : Angle(degrees: 0))
        .onChange(of: selection) { newSelection in
            // Update the external controller and trigger the page changed callback.
            controller.setPage(newSelection)
            onPageChanged?(newSelection)
        }
        .onReceive(controller.$currentPage) { newPage in
            // If the controller changes the page externally, update the selection.
            if newPage != selection {
                withAnimation {
                    selection = newPage
                }
            }
        }
    }
}

/// Example usage of PageView in a preview.
struct PageView_Previews: PreviewProvider {
    static var previews: some View {
        let controller = PageController()
        VStack {
            HStack {
                Button("Previous Page") {
                    controller.previousPage()
                }
                Button("Next Page") {
                    controller.nextPage(totalPages: 3)
                }
            }
            .padding()
            
            PageView(
                scrollDirection: .horizontal,
                pageSnapping: true,
                reverse: false,
                padEnds: true,
                controller: controller,
                onPageChanged: { pageIndex in
                    print("Current Page:", pageIndex)
                },
                pages: [
                    AnyView(Text("Page 1")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color.red)),
                    AnyView(Text("Page 2")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color.green)),
                    AnyView(Text("Page 3")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color.blue))
                ]
            )
            .frame(height: 300)
            .border(Color.gray)
        }
        .previewLayout(.sizeThatFits)
    }
}

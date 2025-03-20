import SwiftUI


/// A simple wrapper that delays building its content until it is needed.
public struct LazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @escaping () -> Content) {
        self.build = build
    }
    public var body: some View {
        build()
    }
}

/// A controller for programmatically controlling a PageView.
/// The controller exposes methods to set the current page, retrieve the current page,
/// and move to the next or previous page.
/// A protocol for controlling the page view externally.
public class PageController: ObservableObject {
    @Published var currentPage: Int = 0
    
    func setPage(_ pageIndex: Int) {
        currentPage = pageIndex
    }
    
    func getCurrentPage() -> Int {
        currentPage
    }
    
    func nextPage(totalPages: Int) {
        currentPage = min(currentPage + 1, totalPages - 1)
    }
    
    func previousPage() {
        currentPage = max(currentPage - 1, 0)
    }
}

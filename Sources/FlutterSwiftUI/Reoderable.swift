import SwiftUI

/// A view that displays a reorderable list of items, allowing users to drag and drop
/// items to rearrange their order. This is similar to Flutter's ReorderableListView.
///
/// Example usage:
/// ```swift
/// struct Item: Identifiable {
///     let id: Int
///     let label: String
/// }
///
/// struct ContentView: View {
///     @State private var items: [Item] = [
///         Item(id: 1, label: "Item 1"),
///         Item(id: 2, label: "Item 2"),
///         Item(id: 3, label: "Item 3")
///     ]
///
///     var body: some View {
///         ReorderableList(items: $items, onReorder: { newItems in
///             items = newItems
///         }) { item, index in
///             Text(item.label)
///                 .padding()
///                 .background(Color.gray.opacity(0.2))
///                 .cornerRadius(8)
///         }
///     }
/// }
/// ```
///
/// - Parameters:
///   - items: A binding to the array of items to display.
///   - onReorder: An optional callback invoked with the new items order when items are reordered.
///   - content: A view builder that produces the view for each item, receiving the item and its index.
public struct ReorderableList<T: Identifiable, Content: View>: View {
    @Binding var items: [T]
    let onReorder: (([T]) -> Void)?
    let content: (T, Int) -> Content

    /// Creates a new `ReorderableList`.
    ///
    /// - Parameters:
    ///   - items: A binding to the array of items.
    ///   - onReorder: A callback that is invoked when the items are reordered.
    ///   - content: A view builder closure that creates a view for each item along with its index.
    public init(
        items: Binding<[T]>,
        onReorder: (([T]) -> Void)? = nil,
        @ViewBuilder content: @escaping (T, Int) -> Content
    ) {
        self._items = items
        self.onReorder = onReorder
        self.content = content
    }

    public var body: some View {
        List {
            ForEach(Array(items.enumerated()), id: \.1.id) { index, item in
                content(item, index)
            }
            .onMove { indices, newOffset in
                items.move(fromOffsets: indices, toOffset: newOffset)
                onReorder?(items)
            }
        }
        .listStyle(PlainListStyle())
        // Enable edit mode so the user can drag and drop items
        .environment(\.editMode, .constant(.active))
    }
}

struct ReorderableList_Previews: PreviewProvider {
    struct Item: Identifiable {
        let id: Int
        let label: String
    }

    @State static var items: [Item] = [
        Item(id: 1, label: "Item 1"),
        Item(id: 2, label: "Item 2"),
        Item(id: 3, label: "Item 3")
    ]

    static var previews: some View {
        ReorderableList(items: $items, onReorder: { newItems in
            items = newItems
        }) { item, _ in
            Text(item.label)
                .padding()
                .background(Color.blue.opacity(0.2))
                .cornerRadius(8)
        }
        .previewLayout(.sizeThatFits)
    }
}

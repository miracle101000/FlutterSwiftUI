import Combine

/// A controller class that manages text input and provides reactive updates
///
/// Use this controller to programmatically manage text input fields and observe changes.
/// It supports multiple listeners and automatic cleanup.
///
/// Example usage:
/// ```swift
/// let controller = TextEditingController(initialText: "Hello")
///
/// // Add listener
/// let cancellable = controller.addListener { newText in
///     print("Text changed to: \(newText)")
/// }
///
/// // Programmatic update
/// controller.text = "Updated text"
///
/// // Cleanup
/// controller.removeListener(cancellable)
/// ```
public class TextEditingController: ObservableObject {
    /// The current text value (Published for SwiftUI binding)
    @Published var text: String
    
    /// Internal storage for active listeners
    private var listeners = Set<AnyCancellable>()
    
    /// Initializes the controller with optional initial text
    /// - Parameter initialText: The starting text value (default: "")
    public init(initialText: String = "") {
        self.text = initialText
    }
    
    /// Add a listener to receive text change notifications
    /// - Parameter listener: Closure to execute on text changes
    /// - Returns: Cancellable token to manage listener lifecycle
    public func addListener(_ listener: @escaping (String) -> Void) -> AnyCancellable {
        let cancellable = $text
            .sink(receiveValue: listener)
        listeners.insert(cancellable)
        return cancellable
    }
    
    /// Remove a specific listener
    /// - Parameter cancellable: The cancellable token returned from addListener
    public func removeListener(_ cancellable: AnyCancellable) {
        cancellable.cancel()
        listeners.remove(cancellable)
    }
    
    /// Clear the current text value and notify listeners
    public func clear() {
        text = ""
    }
    
    /// Dispose all listeners and reset the controller
    public func dispose() {
        listeners.forEach { $0.cancel() }
        listeners.removeAll()
    }
}

/// An enumeration representing horizontal alignment options (main axis alignment) for a Row.
/// Some cases (like spaceBetween, spaceAround, spaceEvenly) are not directly supported in SwiftUI.
public enum MainAxisAlignment {
    case start, end, center, spaceBetween, spaceAround, spaceEvenly
}

/// An enumeration representing vertical alignment options (cross axis alignment) for a Row.
public enum CrossAxisAlignment {
    case start, end, center, stretch, baseline
}

/// An enumeration that determines whether the Row should expand to fill the available space
/// or take the minimum size.
public enum MainAxisSize {
    case max, min
}

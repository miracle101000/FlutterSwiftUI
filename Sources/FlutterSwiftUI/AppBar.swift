import SwiftUI

/// A customizable app bar similar to Flutter's AppBar.
///
/// This component provides a top navigation bar with an optional leading view,
/// a title that can be any SwiftUI view, and multiple action buttons.
///
/// - Parameters:
///   - title: The optional title view (default: empty `Text("")`).
///   - leading: An optional leading view (e.g., a back button) (default: `nil`).
///   - actions: An optional array of action views (e.g., buttons or icons) (default: empty array).
///   - backgroundColor: The background color of the app bar (default: purple).
///   - foregroundColor: The color of text and icons (default: white).
///   - elevation: The shadow elevation of the app bar (default: 4).
public struct AppBar: View {
    let title: AnyView
    let leading: AnyView?
    let actions: [AnyView]
    let backgroundColor: Color
    let foregroundColor: Color
    let elevation: CGFloat

    /// Initializes an `AppBar` with fully optional parameters.
    /// - Parameters:
    ///   - title: The optional title view (defaults to an empty `Text`).
    ///   - leading: An optional view displayed on the left side (e.g., a back button).
    ///   - actions: An optional array of views displayed on the right side.
    ///   - backgroundColor: The background color of the app bar.
    ///   - foregroundColor: The color of the title and icons.
    ///   - elevation: The elevation (shadow) of the app bar.
    public init(
        title: AnyView = AnyView(Text("").font(.headline)), // Default empty text
        leading: AnyView? = nil,
        actions: [AnyView] = [],
        backgroundColor: Color = Color.purple,
        foregroundColor: Color = Color.white,
        elevation: CGFloat = 4
    ) {
        self.title = title
        self.leading = leading
        self.actions = actions
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.elevation = elevation
    }

    public var body: some View {
        HStack {
            // Leading icon/button
            if let leading = leading {
                leading
                    .foregroundColor(foregroundColor)
                    .padding(.leading, 16)
            } else {
                Spacer().frame(width: 40) // Placeholder to align title in center
            }

            // Title centered
            title
                .foregroundColor(foregroundColor)
                .frame(maxWidth: .infinity, alignment: .center)

            // Actions (aligned to the right)
            HStack(spacing: 10) {
                ForEach(actions.indices, id: \.self) { index in
                    actions[index]
                        .foregroundColor(foregroundColor)
                }
            }
            .padding(.trailing, 16)
        }
        .frame(height: 56) // Standard app bar height
        .background(backgroundColor)
        .shadow(color: Color.black.opacity(0.1), radius: elevation, y: elevation) // Shadow effect
    }
}

//Example
struct AppBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            AppBar(
                title: AnyView(
                    HStack {
                        Image(systemName: "star.fill")
                        Text("Custom Title")
                    }
                    .font(.headline)
                ),
                leading: AnyView(
                    Button(action: {
                        print("Back pressed")
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                    }
                ),
                actions: [
                    AnyView(
                        Button(action: {
                            print("Search pressed")
                        }) {
                            Image(systemName: "magnifyingglass")
                                .font(.title2)
                        }
                    ),
                    AnyView(
                        Button(action: {
                            print("Profile pressed")
                        }) {
                            Image(systemName: "person.circle")
                                .font(.title2)
                        }
                    )
                ]
            )
            Spacer()
        }
    }
}

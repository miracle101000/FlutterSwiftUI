import SwiftUI

/// A view that displays a customizable tab bar with an animated indicator, using lazy loading for the tab labels.
public struct TabBarView<Label: View, Content: View>: View {
    @Binding var selectedIndex: Int
    let onTabChange: ((Int) -> Void)?
    let tabs: [Label]
    let indicatorColor: Color
    let indicatorWeight: CGFloat
    let indicatorPadding: CGFloat
    let labelColor: Color
    let unselectedLabelColor: Color
    let content: [Content]
    
    // Use a LazyHStack for tab labels
    public var body: some View {
        VStack(spacing: 0) {
            // Tab bar area
            GeometryReader { geometry in
                let totalWidth = geometry.size.width
                let tabWidth = totalWidth / CGFloat(tabs.count)
                
                ZStack(alignment: .topLeading) {
                    // LazyHStack for lazy loading of tab labels
                    LazyHStack(spacing: 0) {
                        ForEach(0..<tabs.count, id: \.self) { index in
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedIndex = index
                                    onTabChange?(index)
                                }
                            }) {
                                tabs[index]
                                    .foregroundColor(selectedIndex == index ? labelColor : unselectedLabelColor)
                                    .frame(width: tabWidth, alignment: .center)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .frame(width: totalWidth)
                    
                    // Active tab indicator
                    Rectangle()
                        .fill(indicatorColor)
                        .frame(
                            width: tabWidth - indicatorPadding * 2,
                            height: indicatorWeight
                        )
                        .padding(.horizontal, indicatorPadding)
                        .offset(x: CGFloat(selectedIndex) * tabWidth, y: geometry.size.height - indicatorWeight)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedIndex)
                }
            }
            .frame(height: 50)
            
            Divider()
            
            // Content for the selected tab
            content[selectedIndex]
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(UIColor.systemBackground))
        }
    }
}

// MARK: - Preview
struct TabBarView_Previews: PreviewProvider {
    struct TabLabel: View {
        let text: String
        var body: some View {
            Text(text)
                .fontWeight(.medium)
        }
    }
    
    struct TabContent: View {
        let text: String
        var body: some View {
            Text(text)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(UIColor.secondarySystemBackground))
        }
    }
    
    @State static var selectedIndex = 0
    static var previews: some View {
        VStack {
            TabBarView(
                selectedIndex: $selectedIndex,
                onTabChange: { index in
                    print("Tab changed to \(index)")
                },
                tabs: [
                    TabLabel(text: "Tab 1"),
                    TabLabel(text: "Tab 2"),
                    TabLabel(text: "Tab 3"),
                    // If you add many tabs, LazyHStack will only load visible ones.
                ],
                indicatorColor: .green,
                indicatorWeight: 2,
                indicatorPadding: 10,
                labelColor: .white,
                unselectedLabelColor: .gray,
                content: [
                    TabContent(text: "Tab 1 Content: This is the first tab"),
                    TabContent(text: "Tab 2 Content: This is the second tab"),
                    TabContent(text: "Tab 3 Content: This is the third tab")
                ]
            )
            .border(Color.gray)
        }
        .frame(height: 300)
        .previewLayout(.sizeThatFits)
    }
}

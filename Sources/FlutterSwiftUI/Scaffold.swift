import SwiftUI


/**
    A customizable Scaffold component that mimics Flutter's Scaffold structure.
    
    - Parameters:
      - appBar: An optional view for the app bar.
      - drawer: An optional view for the left-side drawer.
      - endDrawer: An optional view for the right-side drawer.
      - floatingActionButton: An optional view for the floating action button.
      - bottomNavigation: An optional view for the bottom navigation bar.
      - snackBar: An optional view for the snack bar.
      - backgroundColor: The scaffold's background color.
      - appBarColor: Optional background color for the app bar.
      - drawerColor: Optional background color for the drawer.
      - endDrawerColor: Optional background color for the end drawer.
      - fabColor: Optional background color for the FAB.
      - elevation: The elevation (shadow) level for components.
      - statusBarColor: Optional color for the status bar area.
      - safeArea: Boolean flag to enable safe area insets.
      - drawerOpen: Indicates if the left drawer should start open.
      - endDrawerOpen: Indicates if the right drawer should start open.
      - onDrawerToggle: Callback when the left drawer is toggled.
      - onEndDrawerToggle: Callback when the right drawer is toggled.
      - drawerDismissible: Boolean flag to allow left drawer dismissal.
      - endDrawerDismissible: Boolean flag to allow right drawer dismissal.
      - fabPosition: The alignment for the floating action button.
      - content: A view builder that defines the main content.
*/
public struct Scaffold<Content: View>: View {
    let appBar: AnyView?
    let drawer: AnyView?
    let endDrawer: AnyView?  // ✅ Added endDrawer
    let floatingActionButton: AnyView?
    let bottomNavigation: AnyView?
    let snackBar: AnyView?
    let backgroundColor: Color
    let appBarColor: Color?
    let drawerColor: Color?
    let endDrawerColor: Color?  // ✅ Added endDrawerColor
    let fabColor: Color?
    let elevation: CGFloat
    let statusBarColor: Color?
    let safeArea: Bool
    let drawerOpen: Bool
    let endDrawerOpen: Bool  // ✅ Added endDrawerOpen
    let onDrawerToggle: ((Bool) -> Void)?
    let onEndDrawerToggle: ((Bool) -> Void)?  // ✅ Added onEndDrawerToggle
    let drawerDismissible: Bool
    let endDrawerDismissible: Bool  // ✅ Added endDrawerDismissible
    let fabPosition: Alignment
    let content: Content
    
    @State private var isDrawerOpen: Bool
    @State private var isEndDrawerOpen: Bool  // ✅ Added isEndDrawerOpen

    public init(
        appBar: AnyView? = nil,
        drawer: AnyView? = nil,
        endDrawer: AnyView? = nil,  // ✅ Added endDrawer
        floatingActionButton: AnyView? = nil,
        bottomNavigation: AnyView? = nil,
        snackBar: AnyView? = nil,
        backgroundColor: Color = .white,
        appBarColor: Color? = nil,
        drawerColor: Color? = nil,
        endDrawerColor: Color? = nil,  // ✅ Added endDrawerColor
        fabColor: Color? = nil,
        elevation: CGFloat = 4,
        statusBarColor: Color? = nil,
        safeArea: Bool = true,
        drawerOpen: Bool = false,
        endDrawerOpen: Bool = false,  // ✅ Added endDrawerOpen
        onDrawerToggle: ((Bool) -> Void)? = nil,
        onEndDrawerToggle: ((Bool) -> Void)? = nil,  // ✅ Added onEndDrawerToggle
        drawerDismissible: Bool = true,
        endDrawerDismissible: Bool = true,  // ✅ Added endDrawerDismissible
        fabPosition: Alignment = .bottomTrailing,
        @ViewBuilder content: () -> Content
    ) {
        self.appBar = appBar
        self.drawer = drawer
        self.endDrawer = endDrawer  // ✅ Added endDrawer
        self.floatingActionButton = floatingActionButton
        self.bottomNavigation = bottomNavigation
        self.snackBar = snackBar
        self.backgroundColor = backgroundColor
        self.appBarColor = appBarColor
        self.drawerColor = drawerColor
        self.endDrawerColor = endDrawerColor  // ✅ Added endDrawerColor
        self.fabColor = fabColor
        self.elevation = elevation
        self.statusBarColor = statusBarColor
        self.safeArea = safeArea
        self.drawerOpen = drawerOpen
        self.endDrawerOpen = endDrawerOpen  // ✅ Added endDrawerOpen
        self.onDrawerToggle = onDrawerToggle
        self.onEndDrawerToggle = onEndDrawerToggle  // ✅ Added onEndDrawerToggle
        self.drawerDismissible = drawerDismissible
        self.endDrawerDismissible = endDrawerDismissible  // ✅ Added endDrawerDismissible
        self.fabPosition = fabPosition
        self.content = content()
        self._isDrawerOpen = State(initialValue: drawerOpen)
        self._isEndDrawerOpen = State(initialValue: endDrawerOpen)  // ✅ Added endDrawerOpen state
    }
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                if let appBar = appBar {
                    appBar
                        .background(appBarColor ?? .clear)
                        .shadow(radius: elevation)
                }
                
                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(backgroundColor)
                    .padding(safeArea ? EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0) : EdgeInsets())

                if let bottomNavigation = bottomNavigation {
                    bottomNavigation
                }
            }

            if let floatingActionButton = floatingActionButton {
                VStack {
                    Spacer()
                    HStack {
                        if fabPosition == .bottomLeading || fabPosition == .topLeading {
                            floatingActionButton.padding()
                            Spacer()
                        } else {
                            Spacer()
                            floatingActionButton.padding()
                        }
                    }
                }
                .background(fabColor ?? .clear)
            }

            if let snackBar = snackBar {
                snackBar
                    .padding()
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(8)
                    .padding(.bottom, 20)
            }

            // Left Drawer
            if let drawer = drawer, isDrawerOpen {
                HStack {
                    drawer
                        .frame(width: 250)
                        .background(drawerColor ?? .clear)
                        .shadow(radius: elevation)
                    
                    if drawerDismissible {
                        Spacer()
                            .background(Color.black.opacity(0.3))
                            .onTapGesture {
                                toggleDrawer()
                            }
                    }
                }
            }

            // Right Drawer (endDrawer)
            if let endDrawer = endDrawer, isEndDrawerOpen {
                HStack {
                    if endDrawerDismissible {
                        Spacer()
                            .background(Color.black.opacity(0.3))
                            .onTapGesture {
                                toggleEndDrawer()
                            }
                    }

                    endDrawer
                        .frame(width: 250)
                        .background(endDrawerColor ?? .clear)
                        .shadow(radius: elevation)
                }
            }
        }
        .onAppear {
            if let statusBarColor = statusBarColor {
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = scene.windows.first {
                    window.rootViewController?.view.backgroundColor = UIColor(statusBarColor)
                }
            }
        }
    }
    
    private func toggleDrawer() {
        isDrawerOpen.toggle()
        onDrawerToggle?(isDrawerOpen)
    }

    private func toggleEndDrawer() {
        isEndDrawerOpen.toggle()
        onEndDrawerToggle?(isEndDrawerOpen)
    }
}

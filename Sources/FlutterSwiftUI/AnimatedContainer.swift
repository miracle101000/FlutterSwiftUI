import SwiftUI

/// An enumeration for simple shadow sizes.
public enum ShadowStyle: String {
    case sm, md, lg
    var radius: CGFloat {
        switch self {
        case .sm: return 3
        case .md: return 6
        case .lg: return 10
        }
    }
    var x: CGFloat {
        switch self {
        case .sm: return 1
        case .md: return 2
        case .lg: return 3
        }
    }
    var y: CGFloat {
        switch self {
        case .sm: return 1
        case .md: return 2
        case .lg: return 3
        }
    }
}

/// A SwiftUI view that mimics a flexible animated container similar to a React component with support for gradients, shadows, and animations.
///
/// This view supports:
/// - Custom padding (individual edges, horizontal/vertical, or uniform).
/// - Simulated margin (via an outer padding).
/// - Background colors or gradients (linear, radial, or sweep).
/// - Border styling with an optional gradient overlay.
/// - A shadow effect using simple shadow presets.
/// - Fixed width/height, transform (via transformEffect), and an animation duration.
/// - A simulated onEnd callback triggered when the animation completes.
public struct AnimatedContainer<Content: View>: View {
    // MARK: Layout Properties
    let padding: CGFloat?
    let paddingTop: CGFloat?
    let paddingRight: CGFloat?
    let paddingBottom: CGFloat?
    let paddingLeft: CGFloat?
    let paddingHorizontal: CGFloat?
    let paddingVertical: CGFloat?
    
    /// Margin is not built-in in SwiftUI; here we simulate it with outer padding.
    let margin: CGFloat?
    let marginTop: CGFloat?
    let marginRight: CGFloat?
    let marginBottom: CGFloat?
    let marginLeft: CGFloat?
    let marginHorizontal: CGFloat?
    let marginVertical: CGFloat?
    
    // MARK: Visual Properties
    let backgroundColor: Color?
    
    /// If provided, this is a uniform corner radius. (For individual corner radii a custom shape would be needed.)
    let borderRadius: CGFloat?
    let border: Color?
    let borderThickness: CGFloat
    
    /// A gradient for the border. If provided, it will override the static border color.
    let borderGradient: LinearGradient?
    
    let shadow: ShadowStyle?
    let boxShadow: Color?
    
    // Background gradients (if provided, these override backgroundColor)
    let linearGradient: LinearGradient?
    let radialGradient: RadialGradient?
    let sweepGradient: AngularGradient?
    
    let width: CGFloat?
    let height: CGFloat?
    
    // MARK: Animation Properties
    let animationDuration: Double
    let transform: CGAffineTransform?
    let onEnd: (() -> Void)?
    
    // MARK: Content
    let content: Content
    
    /// Initializes a new AnimatedContainer.
    /// - Parameters:
    ///   - padding: Uniform padding (overridden by individual edge values if provided).
    ///   - paddingTop: Padding for the top edge.
    ///   - paddingRight: Padding for the right edge.
    ///   - paddingBottom: Padding for the bottom edge.
    ///   - paddingLeft: Padding for the left edge.
    ///   - paddingHorizontal: Horizontal padding (left/right) if individual values are not provided.
    ///   - paddingVertical: Vertical padding (top/bottom) if individual values are not provided.
    ///   - margin: Uniform margin (simulated via outer padding).
    ///   - marginTop: Top margin.
    ///   - marginRight: Right margin.
    ///   - marginBottom: Bottom margin.
    ///   - marginLeft: Left margin.
    ///   - marginHorizontal: Horizontal margin.
    ///   - marginVertical: Vertical margin.
    ///   - backgroundColor: A static background color.
    ///   - borderRadius: Uniform corner radius.
    ///   - border: A static border color.
    ///   - borderThickness: The thickness of the border.
    ///   - borderGradient: An optional gradient to use for the border.
    ///   - shadow: A simple shadow preset (.sm, .md, .lg).
    ///   - boxShadow: Color for the shadow (defaults to a semi-transparent black if not provided).
    ///   - linearGradient: A linear gradient background.
    ///   - radialGradient: A radial gradient background.
    ///   - sweepGradient: A sweep (angular) gradient background.
    ///   - width: Fixed width of the container.
    ///   - height: Fixed height of the container.
    ///   - animationDuration: Duration of the animations in seconds.
    ///   - transform: A CGAffineTransform to apply (e.g. scale, rotation).
    ///   - onEnd: Callback called after the animation completes.
    ///   - content: A view builder that defines the container's content.
    public init(
        padding: CGFloat? = nil,
        paddingTop: CGFloat? = nil,
        paddingRight: CGFloat? = nil,
        paddingBottom: CGFloat? = nil,
        paddingLeft: CGFloat? = nil,
        paddingHorizontal: CGFloat? = nil,
        paddingVertical: CGFloat? = nil,
        margin: CGFloat? = nil,
        marginTop: CGFloat? = nil,
        marginRight: CGFloat? = nil,
        marginBottom: CGFloat? = nil,
        marginLeft: CGFloat? = nil,
        marginHorizontal: CGFloat? = nil,
        marginVertical: CGFloat? = nil,
        backgroundColor: Color? = nil,
        borderRadius: CGFloat? = nil,
        border: Color? = nil,
        borderThickness: CGFloat = 1,
        borderGradient: LinearGradient? = nil,
        shadow: ShadowStyle? = nil,
        boxShadow: Color? = nil,
        linearGradient: LinearGradient? = nil,
        radialGradient: RadialGradient? = nil,
        sweepGradient: AngularGradient? = nil,
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        animationDuration: Double = 0.5,
        transform: CGAffineTransform? = nil,
        onEnd: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.paddingTop = paddingTop
        self.paddingRight = paddingRight
        self.paddingBottom = paddingBottom
        self.paddingLeft = paddingLeft
        self.paddingHorizontal = paddingHorizontal
        self.paddingVertical = paddingVertical
        
        self.margin = margin
        self.marginTop = marginTop
        self.marginRight = marginRight
        self.marginBottom = marginBottom
        self.marginLeft = marginLeft
        self.marginHorizontal = marginHorizontal
        self.marginVertical = marginVertical
        
        self.backgroundColor = backgroundColor
        self.borderRadius = borderRadius
        self.border = border
        self.borderThickness = borderThickness
        self.borderGradient = borderGradient
        
        self.shadow = shadow
        self.boxShadow = boxShadow
        
        self.linearGradient = linearGradient
        self.radialGradient = radialGradient
        self.sweepGradient = sweepGradient
        
        self.width = width
        self.height = height
        
        self.animationDuration = animationDuration
        self.transform = transform
        self.onEnd = onEnd
        
        self.content = content()
    }
    
    // MARK: - Computed Modifiers
    
    /// Compute effective padding using specific values first, then horizontal/vertical, then uniform.
    private var effectivePadding: EdgeInsets {
        let top = paddingTop ?? paddingVertical ?? padding ?? 0
        let bottom = paddingBottom ?? paddingVertical ?? padding ?? 0
        let left = paddingLeft ?? paddingHorizontal ?? padding ?? 0
        let right = paddingRight ?? paddingHorizontal ?? padding ?? 0
        return EdgeInsets(top: top, leading: left, bottom: bottom, trailing: right)
    }
    
    /// Simulate margin by applying outer padding.
    private var effectiveMargin: EdgeInsets {
        let top = marginTop ?? marginVertical ?? margin ?? 0
        let bottom = marginBottom ?? marginVertical ?? margin ?? 0
        let left = marginLeft ?? marginHorizontal ?? margin ?? 0
        let right = marginRight ?? marginHorizontal ?? margin ?? 0
        return EdgeInsets(top: top, leading: left, bottom: bottom, trailing: right)
    }
    
    /// For simplicity, use a uniform corner radius.
    private var effectiveCornerRadius: CGFloat {
        return borderRadius ?? 0
    }
    
    /// Determines the background view based on gradient or solid color.
    @ViewBuilder
    private var backgroundView: some View {
        if let linearGradient = linearGradient {
            linearGradient
        } else if let radialGradient = radialGradient {
            radialGradient
        } else if let sweepGradient = sweepGradient {
            sweepGradient
        } else if let color = backgroundColor {
            color
        } else {
            Color.clear
        }
    }
    
    /// Creates an overlay for the border using either a gradient or a static color.
    @ViewBuilder
    private var borderOverlay: some View {
        if let borderGradient = borderGradient {
            RoundedRectangle(cornerRadius: effectiveCornerRadius)
                .stroke(borderGradient, lineWidth: borderThickness)
        } else if let border = border {
            RoundedRectangle(cornerRadius: effectiveCornerRadius)
                .stroke(border, lineWidth: borderThickness)
        } else {
            EmptyView()
        }
    }
    
    /// Applies a shadow if specified.
    private var shadowModifier: some ViewModifier {
        if let shadow = shadow {
            return AnyViewModifier { view in
                view.shadow(color: boxShadow ?? Color.black.opacity(0.2), radius: shadow.radius, x: shadow.x, y: shadow.y) as! AnyView
            }
        } else {
            return AnyViewModifier { view in view }
        }
    }
    
    // MARK: - Body
    public var body: some View {
        // Use a VStack to simulate margin (outer padding)
        VStack {
            content
                .padding(effectivePadding)
                .frame(width: width, height: height)
                .background(backgroundView)
                .clipShape(RoundedRectangle(cornerRadius: effectiveCornerRadius))
                .overlay(borderOverlay)
                .modifier(shadowModifier)
                // Apply transform if provided (otherwise identity)
                .transformEffect(transform ?? .identity)
                // Animate changes using the specified duration
                .animation(.easeInOut(duration: animationDuration), value: effectivePadding)
        }
        .padding(effectiveMargin)
        .onAppear {
            // Simulate animation end callback after the animationDuration
            DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
                onEnd?()
            }
        }
    }
}

/// A helper view modifier that wraps a transformation closure.
/// This is used to conditionally apply modifiers.
struct AnyViewModifier: ViewModifier {
    let modifier: (AnyView) -> AnyView
    func body(content: Content) -> some View {
        modifier(AnyView(content))
    }
}

struct AnimatedContainer_Previews: PreviewProvider {
    static var previews: some View {
        AnimatedContainer(
            padding: 20,
            backgroundColor: .blue,
            borderRadius: 10,
            border: .white,
            borderThickness: 2,
            shadow: .md,
            width: 300,
            height: 200,
            animationDuration: 0.5,
            transform: CGAffineTransform(scaleX: 1.0, y: 1.0),
            onEnd: { print("Animation complete") }
        ) {
            Text("Hello World")
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .multilineTextAlignment(.center)
        }
        .previewLayout(.sizeThatFits)
    }
}

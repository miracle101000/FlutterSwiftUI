
import SwiftUI

/// A simple enum representing preset shadow sizes.
public enum ShadowType {
    case sm, md, lg
}

/**
 A flexible container view for layout and styling.

 The `Container` view allows you to specify a wide range of style properties such as padding,
 margin, background (solid color or gradient), border (with uniform corner radius), shadow, transform,
 and fixed width/height. This mimics the flexibility of a web container that accepts inline styles.

 ## Example Usage:
 ```swift
 Container(
     padding: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20),
     margin: EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10),
     backgroundColor: .blue,
     borderRadius: 10,
     shadow: .md,
     transform: CGAffineTransform(scaleX: 1.1, y: 1.1),
     width: 300,
     height: 200
 ) {
     VStack {
         Text("Hello World")
             .foregroundColor(.white)
             .font(.title)
     }
 }
 .border(Color.gray)
 ```
 
 ## Properties:
 - **padding**: Internal padding as an `EdgeInsets` (default: none).
 - **margin**: External margin as an `EdgeInsets` (simulated by wrapping in additional padding).
 - **backgroundColor**: The background color of the container.
 - **linearGradient**: An optional linear gradient background.
 - **radialGradient**: An optional radial gradient background.
 - **sweepGradient**: An optional sweep (angular) gradient background.
 - **borderRadius**: The corner radius for rounded corners (applies uniformly).
 - **borderColor** & **borderThickness**: Uniform border color and thickness.
 - **shadow**: A preset shadow size (`sm`, `md`, `lg`).
 - **boxShadow**: A custom shadow style.
 - **transform**: A `CGAffineTransform` applied to the container.
 - **width** & **height**: The fixed dimensions for the container.
 - **content**: The child view(s) to display within the container.
 */
public struct Container<Content: View>: View {
    
    // MARK: - Layout Properties
    let padding: EdgeInsets?
    let margin: EdgeInsets?
    let width: CGFloat?
    let height: CGFloat?
    
    // MARK: - Background & Styling
    let backgroundColor: Color?
    let linearGradient: LinearGradient?
    let radialGradient: RadialGradient?
    let sweepGradient: AngularGradient?
    
    // MARK: - Border Properties
    /// Uniform corner radius
    let borderRadius: CGFloat?
    /// Uniform border properties (color and thickness)
    let borderColor: Color?
    let borderThickness: CGFloat?
    
    // MARK: - Shadow Properties
    let shadow: ShadowType?
    let boxShadow: ShadowStyle?
    
    // MARK: - Transform
    let transform: CGAffineTransform?
    
    // MARK: - Content
    let content: Content
    
    // MARK: - Initializer
    public init(
        padding: EdgeInsets? = nil,
        margin: EdgeInsets? = nil,
        backgroundColor: Color? = nil,
        linearGradient: LinearGradient? = nil,
        radialGradient: RadialGradient? = nil,
        sweepGradient: AngularGradient? = nil,
        borderRadius: CGFloat? = nil,
        borderColor: Color? = nil,
        borderThickness: CGFloat? = nil,
        shadow: ShadowType? = nil,
        boxShadow: ShadowStyle? = nil,
        transform: CGAffineTransform? = nil,
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.margin = margin
        self.backgroundColor = backgroundColor
        self.linearGradient = linearGradient
        self.radialGradient = radialGradient
        self.sweepGradient = sweepGradient
        self.borderRadius = borderRadius
        self.borderColor = borderColor
        self.borderThickness = borderThickness
        self.shadow = shadow
        self.boxShadow = boxShadow
        self.transform = transform
        self.width = width
        self.height = height
        self.content = content()
    }
    
    // MARK: - Body
    public var body: some View {
        // Start with the inner content view
        var view = AnyView(content)
        
        // Apply padding (internal)
        if let padding = padding {
            view = AnyView(view.padding(padding))
        }
        
        // Set fixed width and height if provided
        view = AnyView(view.frame(width: width, height: height))
        
        // Apply background: use gradients if provided, else background color.
        if let linearGradient = linearGradient {
            view = AnyView(view.background(linearGradient))
        } else if let radialGradient = radialGradient {
            view = AnyView(view.background(radialGradient))
        } else if let sweepGradient = sweepGradient {
            view = AnyView(view.background(sweepGradient))
        } else if let backgroundColor = backgroundColor {
            view = AnyView(view.background(backgroundColor))
        }
        
        // Apply uniform border if specified.
        if let thickness = borderThickness, let borderColor = borderColor {
            // Using RoundedRectangle overlay to simulate border.
            view = AnyView(view.overlay(
                RoundedRectangle(cornerRadius: borderRadius ?? 0)
                    .stroke(borderColor, lineWidth: thickness)
            ))
        }
        
        // Apply corner radius if provided.
        if let borderRadius = borderRadius {
            view = AnyView(view.cornerRadius(borderRadius))
        }
        
        // Apply shadow if specified.
        if let shadow = shadow {
            let shadowRadius: CGFloat
            switch shadow {
            case .sm: shadowRadius = 3
            case .md: shadowRadius = 6
            case .lg: shadowRadius = 10
            }
            view = AnyView(view.shadow(color: .black.opacity(0.2), radius: shadowRadius, x: 0, y: 0))
        }
        
        // Apply transform if provided.
        if let transform = transform {
            view = AnyView(view.transformEffect(transform))
        }
        
        // Apply margin (simulate by adding extra padding outside the view).
        if let margin = margin {
            view = AnyView(view.padding(margin))
        }
        
        return view
    }
}

// MARK: - Preview
struct Container_Previews: PreviewProvider {
    static var previews: some View {
        Container(
            padding: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20),
            margin: EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10),
            backgroundColor: .blue,
            borderRadius: 10,
            shadow: .md,
            transform: CGAffineTransform(scaleX: 1.1, y: 1.1),
            width: 300,
            height: 200
        ) {
            VStack {
                Text("Hello World")
                    .foregroundColor(.white)
                    .font(.title)
            }
        }
        .border(Color.gray)
    }
}

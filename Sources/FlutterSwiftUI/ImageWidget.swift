import SwiftUI
import Combine

/// A SwiftUI view that displays images with advanced features including multiple source types,
/// loading states, error handling, and customizable styling
public struct ImageWidget: View {
    // MARK: - Configuration Properties
    
    /// The image source type (URL, Data, or UIImage)
    public enum ImageSource {
        case url(URL)
        case data(Data)
        case uiImage(UIImage)
    }
    
    // MARK: - Parameters
    
    let source: ImageSource
    let altText: String
    let borderRadius: BorderRadius
    let loadingPlaceholder: AnyView?
    let errorPlaceholder: AnyView?
    let width: CGFloat?
    let height: CGFloat?
    let boxFit: ContentMode
    let onLoad: (() -> Void)?
    let onError: ((Error) -> Void)?
    
    // MARK: - State Management
    
    @State private var image: UIImage? = nil
    @State private var isLoading = true
    @State private var hasError = false
    @State private var cancellable: AnyCancellable?
    
    // MARK: - Initializers
    
    public init(
        source: ImageSource,
        altText: String = "",
        borderRadius: BorderRadius = BorderRadius(all: 8),
        loadingPlaceholder: AnyView? = AnyView(ProgressView()),
        errorPlaceholder: AnyView? = AnyView(Text("Failed to load image")),
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        boxFit: ContentMode = .fill,
        onLoad: (() -> Void)? = nil,
        onError: ((Error) -> Void)? = nil
    ) {
        self.source = source
        self.altText = altText
        self.borderRadius = borderRadius
        self.loadingPlaceholder = loadingPlaceholder
        self.errorPlaceholder = errorPlaceholder
        self.width = width
        self.height = height
        self.boxFit = boxFit
        self.onLoad = onLoad
        self.onError = onError
    }
    
    // MARK: - View Body
    
    public var body: some View {
        content
            .frame(width: width, height: height)
            .clipShape(RoundedCornersShape(radius: borderRadius))
            .onAppear(perform: loadImage)
    }
    
    // MARK: - View Components
    
    @ViewBuilder
    private var content: some View {
        if isLoading {
            loadingPlaceholder
        } else if hasError {
            errorPlaceholder
        } else if let image = image {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: boxFit)
        }
    }
    
    // MARK: - Image Loading
    
    private func loadImage() {
        isLoading = true
        hasError = false
        
        switch source {
        case .url(let url):
            loadFromURL(url)
        case .data(let data):
            loadFromData(data)
        case .uiImage(let uiImage):
            self.image = uiImage
            isLoading = false
        }
    }
    
    private func loadFromURL(_ url: URL) {
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .tryMap { data in
                guard let image = UIImage(data: data) else {
                    throw ImageError.invalidImageData
                }
                return image
            }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        handleError(error)
                    }
                },
                receiveValue: { image in
                    self.image = image
                    isLoading = false
                    onLoad?()
                }
            )
    }
    
    private func loadFromData(_ data: Data) {
        guard let image = UIImage(data: data) else {
            handleError(ImageError.invalidImageData)
            return
        }
        self.image = image
        isLoading = false
        onLoad?()
    }
    
    private func handleError(_ error: Error) {
        hasError = true
        isLoading = false
        onError?(error)
    }
}

// MARK: - Supporting Types

/// Custom border radius configuration
public struct BorderRadius : Sendable{
    var topLeft: CGFloat
    var topRight: CGFloat
    var bottomLeft: CGFloat
    var bottomRight: CGFloat
    
    public  init(
        topLeft: CGFloat = 0,
        topRight: CGFloat = 0,
        bottomLeft: CGFloat = 0,
        bottomRight: CGFloat = 0,
        all: CGFloat = 0
    ) {
        self.topLeft = all != 0 ? all : topLeft
        self.topRight = all != 0 ? all : topRight
        self.bottomLeft = all != 0 ? all : bottomLeft
        self.bottomRight = all != 0 ? all : bottomRight
    }
}

/// Custom shape for handling different corner radii
public struct RoundedCornersShape: Shape {
    let radius: BorderRadius
    
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let tl = radius.topLeft
        let tr = radius.topRight
        let bl = radius.bottomLeft
        let br = radius.bottomRight
        
        path.move(to: CGPoint(x: rect.minX + tl, y: rect.minY))
        path.addArc(
            center: CGPoint(x: rect.minX + tl, y: rect.minY + tl),
            radius: tl,
            startAngle: Angle(degrees: -180),
            endAngle: Angle(degrees: -90),
            clockwise: false
        )
        
        path.addLine(to: CGPoint(x: rect.maxX - tr, y: rect.minY))
        path.addArc(
            center: CGPoint(x: rect.maxX - tr, y: rect.minY + tr),
            radius: tr,
            startAngle: Angle(degrees: -90),
            endAngle: Angle(degrees: 0),
            clockwise: false
        )
        
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - br))
        path.addArc(
            center: CGPoint(x: rect.maxX - br, y: rect.maxY - br),
            radius: br,
            startAngle: Angle(degrees: 0),
            endAngle: Angle(degrees: 90),
            clockwise: false
        )
        
        path.addLine(to: CGPoint(x: rect.minX + bl, y: rect.maxY))
        path.addArc(
            center: CGPoint(x: rect.minX + bl, y: rect.maxY - bl),
            radius: bl,
            startAngle: Angle(degrees: 90),
            endAngle: Angle(degrees: 180),
            clockwise: false
        )
        
        return path
    }
}

public enum ImageError: Error {
    case invalidImageData
    case fileReadError
    case unknownSourceType
}

// MARK: - Convenience Initializers

public extension ImageWidget {
    /// Initialize with URL string
    init?(
        url: String?,
        altText: String = "",
        borderRadius: BorderRadius = BorderRadius(all: 8),
        loadingPlaceholder: AnyView? = AnyView(ProgressView()),
        errorPlaceholder: AnyView? = AnyView(Text("Failed to load image")),
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        boxFit: ContentMode = .fill,
        onLoad: (() -> Void)? = nil,
        onError: ((Error) -> Void)? = nil
    ) {
        guard let urlString = url, let validURL = URL(string: urlString) else {
            return nil
        }
        self.init(
            source: .url(validURL),
            altText: altText,
            borderRadius: borderRadius,
            loadingPlaceholder: loadingPlaceholder,
            errorPlaceholder: errorPlaceholder,
            width: width,
            height: height,
            boxFit: boxFit,
            onLoad: onLoad,
            onError: onError
        )
    }
    
    /// Initialize with UIImage
    init(
        uiImage: UIImage,
        altText: String = "",
        borderRadius: BorderRadius = BorderRadius(all: 8),
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        boxFit: ContentMode = .fill,
        onLoad: (() -> Void)? = nil
    ) {
        self.init(
            source: .uiImage(uiImage),
            altText: altText,
            borderRadius: borderRadius,
            loadingPlaceholder: nil,
            errorPlaceholder: nil,
            width: width,
            height: height,
            boxFit: boxFit,
            onLoad: onLoad
        )
    }
}

// MARK: - Preview

struct ImageWidget_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            // URL example
            ImageWidget(
                url: "https://example.com/image.jpg",
                width: 200,
                height: 150
            )
            
            // Data example
            if let data = UIImage(systemName: "photo")?.pngData() {
                ImageWidget(
                    source: .data(data),
                    width: 200,
                    height: 150
                )
            }
        }
    }
}

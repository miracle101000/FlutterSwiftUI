import SwiftUI

/// A customizable carousel view for displaying slides in a paging layout.
///
/// This view supports a variety of features:
/// - Autoplay with a specified interval and animation duration.
/// - Infinite scrolling (looping through slides).
/// - Reversed scroll direction.
/// - Enlargement of the center slide.
/// - Customizable viewport fraction (how much of the view each slide occupies).
/// - Manual navigation via arrow buttons and pagination dots.
/// - A callback when the active page changes.
///
/// Example usage:
/// ```swift
/// Carousel(
///     slides: [
///         AnyView(Rectangle().fill(Color.red)),
///         AnyView(Rectangle().fill(Color.green)),
///         AnyView(Rectangle().fill(Color.blue))
///     ],
///     height: 400,
///     aspectRatio: 1.0,
///     initialPage: 0,
///     enableInfiniteScroll: true,
///     reverse: false,
///     autoPlay: true,
///     autoPlayInterval: 3.0,
///     autoPlayAnimationDuration: 0.5,
///     autoPlayCurve: .easeInOut,
///     enlargeCenterPage: true,
///     enlargeFactor: 1.2,
///     onPageChanged: { index in print("Page changed to: \(index)") },
///     scrollDirection: .horizontal,
///     viewportFraction: 0.8
/// )
/// .frame(width: 300, height: 400)
/// ```
///
/// - Note: This is a simplified implementation that uses a horizontal ScrollView with paging behavior.
public struct Carousel<Content: View>: View {
    // MARK: - Properties
    let slides: [Content]
    let height: CGFloat
    let aspectRatio: CGFloat
    let initialPage: Int
    let enableInfiniteScroll: Bool
    let reverse: Bool
    let autoPlay: Bool
    let autoPlayInterval: Double
    let autoPlayAnimationDuration: Double
    let autoPlayCurve: Animation
    let enlargeCenterPage: Bool
    let enlargeFactor: CGFloat
    let onPageChanged: ((Int) -> Void)?
    let scrollDirection: Axis.Set
    let viewportFraction: CGFloat
    
    // MARK: - State
    @State private var currentIndex: Int
    @State private var isPlaying: Bool
    @State private var timer: Timer? = nil
    
    // MARK: - Initializer
    public init(
        slides: [Content],
        height: CGFloat,
        aspectRatio: CGFloat,
        initialPage: Int = 0,
        enableInfiniteScroll: Bool = false,
        reverse: Bool = false,
        autoPlay: Bool = false,
        autoPlayInterval: Double = 3.0,
        autoPlayAnimationDuration: Double = 0.5,
        autoPlayCurve: Animation = .easeInOut,
        enlargeCenterPage: Bool = false,
        enlargeFactor: CGFloat = 1.2,
        onPageChanged: ((Int) -> Void)? = nil,
        scrollDirection: Axis.Set = .horizontal,
        viewportFraction: CGFloat = 1.0
    ) {
        self.slides = slides
        self.height = height
        self.aspectRatio = aspectRatio
        self.initialPage = initialPage
        self.enableInfiniteScroll = enableInfiniteScroll
        self.reverse = reverse
        self.autoPlay = autoPlay
        self.autoPlayInterval = autoPlayInterval
        self.autoPlayAnimationDuration = autoPlayAnimationDuration
        self.autoPlayCurve = autoPlayCurve
        self.enlargeCenterPage = enlargeCenterPage
        self.enlargeFactor = enlargeFactor
        self.onPageChanged = onPageChanged
        self.scrollDirection = scrollDirection
        self.viewportFraction = viewportFraction
        _currentIndex = State(initialValue: initialPage)
        _isPlaying = State(initialValue: autoPlay)
    }
    
    // MARK: - Body
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                // The ScrollView for slides.
                ScrollView(scrollDirection, showsIndicators: false) {
                    // Use LazyHStack for horizontal, LazyVStack for vertical.
                    Group {
                        if scrollDirection == .horizontal {
                            LazyHStack(spacing: 0) {
                                ForEach(0..<slides.count, id: \.self) { index in
                                    slideView(for: index, in: geometry)
                                }
                            }
                        } else {
                            LazyVStack(spacing: 0) {
                                ForEach(0..<slides.count, id: \.self) { index in
                                    slideView(for: index, in: geometry)
                                }
                            }
                        }
                    }
                }
                // Offset the content based on the current index.
                .content.offset(x: scrollDirection == .horizontal ? -CGFloat(currentIndex) * geometry.size.width * viewportFraction : 0,
                                y: scrollDirection == .vertical ? -CGFloat(currentIndex) * geometry.size.height * viewportFraction : 0)
                .animation(autoPlayCurve, value: currentIndex)
                
                // Pagination dots
                VStack {
                    Spacer()
                    HStack(spacing: 8) {
                        ForEach(0..<slides.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentIndex ? Color.black : Color.white)
                                .frame(width: 10, height: 10)
                                .onTapGesture {
                                    changePage(to: index)
                                }
                        }
                    }
                    .padding(.bottom, 10)
                }
                
                // Arrow buttons for navigation (if infinite scrolling is enabled)
                if enableInfiniteScroll {
                    HStack {
                        Button(action: prevSlide) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                        Spacer()
                        Button(action: nextSlide) {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 16)
                }
                
                // Play/Pause button for autoplay
                VStack {
                    HStack {
                        Spacer()
                        Button(action: { togglePlay() }) {
                            Text(isPlaying ? "Pause" : "Play")
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.black.opacity(0.5))
                                .cornerRadius(8)
                        }
                    }
                    Spacer()
                }
            }
            .onAppear { startAutoPlay() }
            .onDisappear { stopAutoPlay() }
        }
        // Set the overall frame based on height and aspect ratio.
        .frame(height: height * aspectRatio)
    }
    
    // MARK: - Private Helpers
    
    /// Returns the view for a single slide.
    private func slideView(for index: Int, in geometry: GeometryProxy) -> some View {
        GeometryReader { slideGeometry in
            let slideCenter = slideGeometry.frame(in: .global).midX
            let screenCenter = geometry.size.width / 2
            let scale = enlargeCenterPage ?
                max(1.0, 1 + (enlargeFactor - 1) * (1 - abs(slideCenter - screenCenter) / screenCenter))
                : 1.0
            slides[index]
                .frame(width: geometry.size.width * viewportFraction, height: height)
                .scaleEffect(scale)
                .animation(.easeInOut(duration: autoPlayAnimationDuration), value: scale)
        }
        .frame(width: geometry.size.width * viewportFraction, height: height)
    }
    
    /// Advances to the next slide.
    private func nextSlide() {
        withAnimation(autoPlayCurve) {
            currentIndex = reverse ? currentIndex - 1 : currentIndex + 1
            if enableInfiniteScroll {
                currentIndex = (currentIndex + slides.count) % slides.count
            } else {
                currentIndex = min(max(currentIndex, 0), slides.count - 1)
            }
            onPageChanged?(currentIndex)
        }
    }
    
    /// Goes back to the previous slide.
    private func prevSlide() {
        withAnimation(autoPlayCurve) {
            currentIndex = reverse ? currentIndex + 1 : currentIndex - 1
            if enableInfiniteScroll {
                currentIndex = (currentIndex + slides.count) % slides.count
            } else {
                currentIndex = min(max(currentIndex, 0), slides.count - 1)
            }
            onPageChanged?(currentIndex)
        }
    }
    
    /// Changes the page to the specified index.
    private func changePage(to index: Int) {
        withAnimation(autoPlayCurve) {
            currentIndex = index
            onPageChanged?(index)
        }
    }
    
    // MARK: - Autoplay Methods
    
    /// Starts the autoplay timer if enabled.
    private func startAutoPlay() {
        if autoPlay {
            timer = Timer.scheduledTimer(withTimeInterval: autoPlayInterval, repeats: true) { _ in
                nextSlide()
            }
        }
    }
    
    /// Stops the autoplay timer.
    private func stopAutoPlay() {
        timer?.invalidate()
        timer = nil
    }
    
    /// Toggles autoplay on and off.
    private func togglePlay() {
        isPlaying.toggle()
        if isPlaying {
            startAutoPlay()
        } else {
            stopAutoPlay()
        }
    }
}

// MARK: - Preview
struct Carousel_Previews: PreviewProvider {
    static var previews: some View {
        Carousel(
            slides: [
                AnyView(Rectangle().fill(Color.red)),
                AnyView(Rectangle().fill(Color.green)),
                AnyView(Rectangle().fill(Color.blue))
            ],
            height: 400,
            aspectRatio: 1.0,
            initialPage: 0,
            enableInfiniteScroll: true,
            reverse: false,
            autoPlay: true,
            autoPlayInterval: 3.0,
            autoPlayAnimationDuration: 0.5,
            autoPlayCurve: .easeInOut,
            enlargeCenterPage: true,
            enlargeFactor: 1.2,
            onPageChanged: { index in print("Page changed to: \(index)") },
            scrollDirection: .horizontal,
            viewportFraction: 0.8
        )
        .frame(width: 300, height: 400)
    }
}

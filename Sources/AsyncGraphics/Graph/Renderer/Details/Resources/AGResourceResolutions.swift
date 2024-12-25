import CoreGraphics

struct AGResourceResolutions: Equatable, Sendable {
    #if !os(visionOS)
    let camera: [Graphic.CameraPosition: CGSize]
    #endif
    let image: [AGImage.Source: CGSize]
}

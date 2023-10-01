import CoreGraphics

struct AGResourceResolutions: Equatable {
    #if !os(visionOS)
    let camera: [Graphic.CameraPosition: CGSize]
    #endif
    let image: [AGImage.Source: CGSize]
}

import CoreGraphics

struct AGResourceResolutions: Equatable {
    #if !os(xrOS)
    let camera: [Graphic.CameraPosition: CGSize]
    #endif
    let image: [AGImage.Source: CGSize]
}

import CoreGraphics

struct AGResourceResolutions: Equatable {
    let camera: [Graphic.CameraPosition: CGSize]
    let image: [AGImage.Source: CGSize]
}

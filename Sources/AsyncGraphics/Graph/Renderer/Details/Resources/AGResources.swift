
struct AGResources: Equatable {
    #if !os(xrOS)
    let cameraGraphics: [Graphic.CameraPosition: Graphic]
    let videoGraphics: [GraphicVideoPlayer: Graphic]
    #endif
    let imageGraphics: [AGImage.Source: Graphic]
}

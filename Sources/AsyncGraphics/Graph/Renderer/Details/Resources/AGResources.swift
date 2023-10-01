
struct AGResources: Equatable {
    #if !os(visionOS)
    let cameraGraphics: [Graphic.CameraPosition: Graphic]
    #endif
    let videoGraphics: [GraphicVideoPlayer: Graphic]
    let imageGraphics: [AGImage.Source: Graphic]
}

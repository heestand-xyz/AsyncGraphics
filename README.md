<img src="https://github.com/heestand-xyz/AsyncGraphics/blob/main/Assets/AsyncGraphics-Icon.png?raw=true" width="128px"/>

# AsyncGraphics

AsyncGraphics is a Swift package for working with images and video with async / await. The core type is simply just called [`Graphic`](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic) and it's like an image. A `Graphic` is a reference type backed by a [`MTLTexture`](https://developer.apple.com/documentation/metal/mtltexture).

## Documentation

[**Documentation**](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/) (DocC)

The documentation contains a list of all content and effects that can be created with the [Graphic](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic) type. It also contains articles about setting up a [live camera feed](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/livecamera) and [editing video](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/videoediting).

## Metal

There is also the option to write high level [metal](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/metal) code in AsyncGraphics. No need to setup a pipeline.

## Install

```swift
.package(url: "https://github.com/heestand-xyz/AsyncGraphics", from: "0.9.7")
```

## Camera Example

### Declarative

### Imperative

```swift
import SwiftUI
import AsyncGraphics

struct ContentView: View {
    
    @State private var graphic: Graphic?
    
    var body: some View {
        ZStack {
            if let graphic {
                GraphicView(graphic: graphic)
            }
        }
        .task {
            for await cameraGraphic in try! Graphic.camera(.front) {
                graphic = cameraGraphic
            }
        }
    }
}
```

### Color

Colors are represented with the `PixelColor` type.<br>
`import PixelColor` to create custom colors with hex values.

[PixelColor](https://github.com/heestand-xyz/PixelColor) on GitHub.

### Image

Images are represented with `TMImage`.<br> 
This is a multi platform type alias to `UIImage` and `NSImage`.<br>
`import TextureMap` for extra multi platform methods like `.pngData()` for macOS. 

[TextureMap](https://github.com/heestand-xyz/TextureMap) on GitHub.

### About

AsyncGraphics is a work in progress project, there is more features to come! Feel free to submit a PR!

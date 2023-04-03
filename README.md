<img src="https://github.com/heestand-xyz/AsyncGraphics/blob/main/Assets/AsyncGraphics-Icon.png?raw=true" width="128px"/>

# AsyncGraphics

AsyncGraphics is a Swift package for working with images and video with async / await. The core type is simply just called [`Graphic`](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic) and it's like an image. A `Graphic` is a reference type backed by a [`MTLTexture`](https://developer.apple.com/documentation/metal/mtltexture).

## Documentation

[**Documentation**](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/) (DocC)

The documentation contains a list of all content and effects that can be created with the [Graphic](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic) type. It also contains articles about setting up a [live camera feed](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/livecamera) and [editing video](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/videoediting).

## Install

```swift
.package(url: "https://github.com/heestand-xyz/AsyncGraphics", from: "1.0.0")
```

## Views

In AsyncGraphics there are a couple ways to present a graphic. You can use the [AGView](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/agview) to declarativly view [AGGraph](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/aggraph)s or [GraphicView](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphicview) to imperartly view [Graphic](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic)s. Then there is the [Graphic3DView](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic3dview) to view [Graphic3D](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic3d/) to view 3d graphics.

## Camera Example

### Declarative

```swift
import SwiftUI
import AsyncGraphics

struct ContentView: View {
    
    var body: some View {
        AGView {
            AGZStack {
                AGCamera(.front)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                AGCircle()
                    .blendMode(.multiply)
            }
        }
    }
}
```

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
            do {
                let resolution = CGSize(width: 1_000, height: 1_000)
                let circleGraphic: Graphic = try await .circle(radius: 500,
                                                               backgroundColor: .clear,
                                                               resolution: resolution)
                for await cameraGraphic in try Graphic.camera(.front) {
                    graphic = try await circleGraphic
                        .blended(with: cameraGraphic,
                                 blendingMode: .multiply,
                                 placement: .fill)
                }
            } catch {
                print(error)
            }
        }
    }
}
```

> Remember to set the Info.plist key `NSCameraUsageDescription` "Privacy - Camera Usage Description"

## Metal

There is the option to write high level [metal](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/metal) code in AsyncGraphics. No need to setup a pipeline.

### Color

Colors are represented with the `PixelColor` type.<br>
`import PixelColor` to create custom colors with hex values.

[PixelColor](https://github.com/heestand-xyz/PixelColor) on GitHub.

### About

AsyncGraphics is a work in progress project, there is more features to come! Feel free to submit a PR!

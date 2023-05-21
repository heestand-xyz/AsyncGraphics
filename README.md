<img src="https://github.com/heestand-xyz/AsyncGraphics/blob/main/Assets/AsyncGraphics-Icon.png?raw=true" width="128px"/>

# AsyncGraphics

AsyncGraphics is a Swift package for working with images and video with async / await. The core type is simply just called [`Graphic`](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic), it's like an image and is backed by a [`MTLTexture`](https://developer.apple.com/documentation/metal/mtltexture).

## Documentation

[**Documentation**](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/) (DocC)

See the [**Graphic**](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic) docs for all effects.

### Articles

- [Blending](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/blending)
- [Layout](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/layout)
- [Video Playback](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/videoplayback)
- [Video Editing](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/videoediting)
- [Live Camera](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/livecamera)

## Install

```swift
.package(url: "https://github.com/heestand-xyz/AsyncGraphics", from: "1.0.0")
```

## Views

In AsyncGraphics there are a couple ways to present a graphic.

- [AGView](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/agview) to declarativly view [AGGraph](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/aggraph)s
- [GraphicView](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphicview) to imperatively view [Graphic](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic)s
- [Graphic3DView](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic3dview) to view [Graphic3D](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic3d/)s

# Examples

## Blending

<img src="http://async.graphics/Images/Articles/async-graphics-blending.png" width="300px"/>

First we create an [AGView](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/agview/), this is the container for all [AGGraph](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/aggraph)s.
In this example we have a [AGZStack](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/agzstack) with 3 [AGHStack](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/aghstack)s. Each graph has a blend mode ([AGBlendMode](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/agblendmode)), in this case .screen.

```swift
import SwiftUI
import AsyncGraphics

struct ContentView: View {
    var body: some View {
        AGView {
            AGZStack {
                AGHStack {
                    AGSpacer()
                    AGCircle()
                        .foregroundColor(.red)
                }
                AGHStack {
                    AGSpacer()
                    AGCircle()
                        .foregroundColor(.green)
                    AGSpacer()
                }
                .blendMode(.screen)
                AGHStack {
                    AGCircle()
                        .foregroundColor(.blue)
                    AGSpacer()
                }
                .blendMode(.screen)
            }
        }
    }
}
```

## Layout

<img src="http://async.graphics/Images/Articles/async-graphics-layout.png" width="300px"/>

First we create an [AGView](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/agview/), this is the container for all [AGGraph](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/aggraph/)s.
In this example we create an [AGHStack](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/aghstack/) to contain out boxes, then we loop 3 times with an [AGForEach](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/agforeach/), calculate the width and create [AGRoundedRectangles](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/agroundedrectangle/). After that we set the frame to get a fixed size and apply a color. After the stack we apply some padding and finally add a background.

```swift
import SwiftUI
import AsyncGraphics

struct ContentView: View {
    var body: some View {
        AGView {
            AGHStack(alignment: .top, spacing: 15) {
                AGForEach(0..<3) { index in
                    let width = 50 * CGFloat(index + 1)
                    AGRoundedRectangle(cornerRadius: 15)
                        .frame(width: width, height: width)
                        .foregroundColor(Color(hue: Double(index) / 3,
                                               saturation: 0.5,
                                               brightness: 1.0))
                }
            }
            .padding(15)
            .background {
                AGRoundedRectangle(cornerRadius: 30)
                    .opacity(0.1)
            }
        }
    }
}
```

## Camera

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

You can also do the same with `Graphic`s:

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

## Colors

Colors are represented with the `PixelColor` type.<br>
`import PixelColor` to create custom colors with hex values.

[PixelColor](https://github.com/heestand-xyz/PixelColor) on GitHub.

## About

AsyncGraphics is a work in progress project, there is more features to come! Feel free to submit a PR!

<img src="https://github.com/heestand-xyz/AsyncGraphics/blob/main/Assets/AsyncGraphics-Icon.png?raw=true" width="128px"/>

# AsyncGraphics

AsyncGraphics is a Swift package for working with images and video with async / await. The core type is simply just called [`Graphic`](http://async.graphics/documentation/asyncgraphics/graphic) and it's like an image, tho backed by a [`MTLTexture`](https://developer.apple.com/documentation/metal/mtltexture) and comes with a lot of content and effects.

AsyncGraphics is a work in progress project, there is more features to come!

## Documentation

[**Documentation**](http://async.graphics/documentation/AsyncGraphics) (DocC)

The documentation contains a list of all content and effects that can be created with the [Graphic](http://async.graphics/documentation/asyncgraphics/graphic) type. It also contains articles about setting up a [live camera feed](http://async.graphics/documentation/asyncgraphics/livecamera) and [editing video](http://async.graphics/documentation/asyncgraphics/videoediting).

## Content

Import an [image](http://async.graphics/documentation/asyncgraphics/graphic/camera(_:device:preset:)), [video](http://async.graphics/documentation/asyncgraphics/graphic/importvideo(url:progress:)) or live stream a [camera](http://async.graphics/documentation/asyncgraphics/graphic/camera(_:device:preset:)) feed.

Create [color](http://async.graphics/documentation/asyncgraphics/graphic/color(_:resolution:options:)), [text](http://async.graphics/documentation/asyncgraphics/graphic/text(_:font:center:horizontalalignment:verticalalignment:color:backgroundcolor:resolution:options:)), [rectangle](http://async.graphics/documentation/asyncgraphics/graphic/rectangle(size:center:cornerradius:color:backgroundcolor:resolution:options:)), [circle](http://async.graphics/documentation/asyncgraphics/graphic/circle(radius:center:color:backgroundcolor:resolution:options:)), [polygon](http://async.graphics/documentation/asyncgraphics/graphic/polygon(count:radius:center:rotation:cornerradius:color:backgroundcolor:resolution:options:)) [gradient](http://async.graphics/documentation/asyncgraphics/graphic/gradient(direction:stops:position:scale:offset:extend:gamma:resolution:options:)), [noise](http://async.graphics/documentation/asyncgraphics/graphic/noise(offset:depth:scale:octaves:seed:resolution:options:)), [particles](http://async.graphics/documentation/asyncgraphics/graphic/uvparticles(particlescale:particlecolor:backgroundcolor:resolution:samplecount:particleoptions:options:)) and more.

## Effects

Effects include [resize](http://async.graphics/documentation/asyncgraphics/graphic/resized(to:placement:)), [blend](http://async.graphics/documentation/asyncgraphics/graphic/blended(with:blendingmode:placement:options:)) with various [blending modes](http://async.graphics/documentation/asyncgraphics/blendingmode), [translate](http://async.graphics/documentation/asyncgraphics/graphic/translated(x:y:options:)), [rotate](http://async.graphics/documentation/asyncgraphics/graphic/rotated(_:options:)), [scale](http://async.graphics/documentation/asyncgraphics/graphic/scaled(_:options:)), [mirror](http://async.graphics/documentation/asyncgraphics/graphic/mirroredvertically()), [stack](http://async.graphics/documentation/asyncgraphics/graphic/vstack(with:alignment:spacing:padding:backgroundcolor:resolution:)), [brightness](http://async.graphics/documentation/asyncgraphics/graphic/brightness(_:)), [contrast](http://async.graphics/documentation/asyncgraphics/graphic/contrast(_:)), [invert](http://async.graphics/documentation/asyncgraphics/graphic/inverted()), [opacity](http://async.graphics/documentation/asyncgraphics/graphic/opacity(_:)), [monochrome](http://async.graphics/documentation/asyncgraphics/graphic/monochrome()), [saturation](http://async.graphics/documentation/asyncgraphics/graphic/saturated(_:)), [hue](http://async.graphics/documentation/asyncgraphics/graphic/hue(_:)), [tint](http://async.graphics/documentation/asyncgraphics/graphic/tinted(_:)), [channel mix](http://async.graphics/documentation/asyncgraphics/graphic/channelmix(red:green:blue:alpha:)), [blur](http://async.graphics/documentation/asyncgraphics/graphic/blurred(radius:)), [rainbow blur](http://async.graphics/documentation/asyncgraphics/graphic/rainbowblurredcircle(radius:angle:light:samplecount:options:)), [displace](http://async.graphics/documentation/asyncgraphics/graphic/displaced(with:offset:origin:placement:options:)), [edge](http://async.graphics/documentation/asyncgraphics/graphic/edge(amplitude:distance:options:)), [clamp](http://async.graphics/documentation/asyncgraphics/graphic/clamp(_:low:high:includealpha:options:)), [cross](http://async.graphics/documentation/asyncgraphics/graphic/cross(with:fraction:placement:options:)), [corner pin](http://async.graphics/documentation/asyncgraphics/graphic/cornerpinned(topleft:topright:bottomleft:bottomright:perspective:subdivisions:backgroundcolor:)), [chroma key](http://async.graphics/documentation/asyncgraphics/graphic/chromakey(color:parameters:options:)) a green screen.

 a graphic and even .

## Metal

There is also the option to write high level [metal](http://async.graphics/documentation/asyncgraphics/graphic/metal(code:resolution:options:)) code in AsyncGraphics. No need to setup a pipeline.

## Install

```swift
.package(url: "https://github.com/heestand-xyz/AsyncGraphics", from: "0.8.0")
```

## Example

A live camera feed.

```swift
import SwiftUI
import AsyncGraphics

struct ContentView: View {
    
    @State private var graphic: Graphic?
    
    var body: some View {
        ZStack {
            if let graphic = graphic {
                GraphicView(graphic: graphic)
            } else {
                ProgressView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task {
            do {
                for await cameraGraphic in try Graphic.camera(.front) {
                    graphic = cameraGraphic
                }
            } catch {
                fatalError()
            }
        }
    }
}
```


## Graphic - Content

A `Graphic` can be created with static funcs e.g. `Graphic.image(named:)` or `Graphic.circle(size:radius:center:)`.

### Color

Colors are represented with the `PixelColor` type.<br>
`import PixelColor` to create custom colors with hex values.

```swift
static func color(_ color: PixelColor, size: CGSize) async throws -> Graphic
```

*Example:*

```swift
import PixelColor
```

```swift
let color: Graphic = try await .color(PixelColor(hex: "#FF8000"), 
                                      size: CGSize(width: 1000, height: 1000))
```

### Image

Images are represented with `TMImage`.<br> 
This is a multi platform type alias to `UIImage` and `NSImage`.<br>
`import TextureMap` for extra multi platform methods like `.pngData()` for macOS. 

```swift
static func image(_ image: TMImage) async throws -> Graphic
```

```swift
static func image(named name: String, in bundle: Bundle = .main) async throws -> Graphic
```

*Example:*

```swift
let image: Graphic = try await .image(named: "Image")
```

### Circle

<img src="https://github.com/heestand-xyz/AsyncGraphics/blob/main/Assets/Graphics/CircleGraphic.png" width="125px"/>

```swift
static func circle(radius: CGFloat? = nil, center: CGPoint? = nil, color: PixelColor = .white, backgroundColor: PixelColor = .black, size: CGSize) async throws -> Graphic
```

*Example:*

```swift
let circle: Graphic = try await .circle(radius: 250.0,
                                        center: CGPoint(x: 500.0, y: 500.0),
                                        color: .orange,
                                        backgroundColor: .clear,
                                        size: CGSize(width: 1000.0, height: 1000.0))
```

### Frames

You can import a video to an array of `Graphic`s.<br>

```swift
static func videoFrames(url: URL) async throws -> [Graphic]
```

*Example:*

```swift
guard let url: URL = Bundle.main.url(forResource: "Video", withExtension: "mov") else { return }
let frames: [Graphic] = try await .videoFrames(url: url)
```


## Graphic - Effects

A `Graphic` can be modified with effect funcs e.g. `.inverted()` or `.blend(graphic:blendingMode:placement:)`.

### Invert

```swift
func inverted() async throws -> Graphic
```

*Example:*

```swift
let inverted: Graphic = try await someGraphic.inverted() 
```

### Blend

```swift
func blended(with graphic: Graphic, blendingMode: BlendingMode, placement: Placement = .fit) async throws -> Graphic
```

*Example:*

```swift
let blended: Graphic = try await someGraphic.blended(with: otherGraphic, blendingMode: .multiply) 
```

### Displace

```swift
func displaced(with graphic: Graphic, offset: CGFloat, origin: PixelColor = .gray, placement: Placement = .fill) async throws -> Graphic
```

*Example:*

```swift
let displaced: Graphic = try await someGraphic.displaced(with: otherGraphic, offset: 100.0) 
```


## Graphic - Export

A `Graphic` can be exported to a video with func `.video(fps:kbps:format:)`.

### Video

```swift
func video(fps: Int = 30, kbps: Int = 1_000, format: VideoFormat = .mov) async throws -> Data
```

*Examples:*

```swift
let frames: [Graphic] = ...
```

```swift
let videoData: Data = try await frames.video(fps: 60, kbps: 750, format: .mp4) 
```

```swift
let videoURL: URL = try await frames.video(fps: 24, kbps: 500, format: .mov) 
```

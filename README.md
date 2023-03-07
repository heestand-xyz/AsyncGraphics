<img src="https://github.com/heestand-xyz/AsyncGraphics/blob/main/Assets/AsyncGraphics-Icon.png?raw=true" width="128px"/>

# AsyncGraphics

AsyncGraphics is a Swift package for working with images and video with async / await. The core type is simply just called [`Graphic`](http://async.graphics/documentation/asyncgraphics/graphic) and it's like an image, tho backed by a [`MTLTexture`](https://developer.apple.com/documentation/metal/mtltexture) and comes with a lot of content and effects.

## Documentation

[**Documentation**](http://async.graphics/documentation/AsyncGraphics) (DocC)

The documentation contains a list of all content and effects that can be created with the [Graphic](http://async.graphics/documentation/asyncgraphics/graphic) type. It also contains articles about setting up a [live camera feed](http://async.graphics/documentation/asyncgraphics/livecamera) and [editing video](http://async.graphics/documentation/asyncgraphics/videoediting).

## Content

Import an [image](http://async.graphics/documentation/asyncgraphics/graphic/camera(_:device:preset:)), [video](http://async.graphics/documentation/asyncgraphics/graphic/importvideo(url:progress:)) or live stream a [camera](http://async.graphics/documentation/asyncgraphics/graphic/camera(_:device:preset:)) feed.

Create [color](http://async.graphics/documentation/asyncgraphics/graphic/color(_:resolution:options:)), [text](http://async.graphics/documentation/asyncgraphics/graphic/text(_:font:center:horizontalalignment:verticalalignment:color:backgroundcolor:resolution:options:)), [rectangle](http://async.graphics/documentation/asyncgraphics/graphic/rectangle(size:center:cornerradius:color:backgroundcolor:resolution:options:)), [circle](http://async.graphics/documentation/asyncgraphics/graphic/circle(radius:center:color:backgroundcolor:resolution:options:)), [polygon](http://async.graphics/documentation/asyncgraphics/graphic/polygon(count:radius:center:rotation:cornerradius:color:backgroundcolor:resolution:options:)) [gradient](http://async.graphics/documentation/asyncgraphics/graphic/gradient(direction:stops:position:scale:offset:extend:gamma:resolution:options:)), [noise](http://async.graphics/documentation/asyncgraphics/graphic/noise(offset:depth:scale:octaves:seed:resolution:options:)), [particles](http://async.graphics/documentation/asyncgraphics/graphic/uvparticles(particlescale:particlecolor:backgroundcolor:resolution:samplecount:particleoptions:options:)) and more.

## Effects

Effects include [resize](http://async.graphics/documentation/asyncgraphics/graphic/resized(to:placement:)), [blend](http://async.graphics/documentation/asyncgraphics/graphic/blended(with:blendingmode:placement:options:)) with various [blending modes](http://async.graphics/documentation/asyncgraphics/blendingmode), [translate](http://async.graphics/documentation/asyncgraphics/graphic/translated(x:y:options:)), [rotate](http://async.graphics/documentation/asyncgraphics/graphic/rotated(_:options:)), [scale](http://async.graphics/documentation/asyncgraphics/graphic/scaled(_:options:)), [mirror](http://async.graphics/documentation/asyncgraphics/graphic/mirroredvertically()), [stack](http://async.graphics/documentation/asyncgraphics/graphic/vstack(with:alignment:spacing:padding:backgroundcolor:resolution:)), [brightness](http://async.graphics/documentation/asyncgraphics/graphic/brightness(_:)), [contrast](http://async.graphics/documentation/asyncgraphics/graphic/contrast(_:)), [invert](http://async.graphics/documentation/asyncgraphics/graphic/inverted()), [opacity](http://async.graphics/documentation/asyncgraphics/graphic/opacity(_:)), [monochrome](http://async.graphics/documentation/asyncgraphics/graphic/monochrome()), [saturation](http://async.graphics/documentation/asyncgraphics/graphic/saturated(_:)), [hue](http://async.graphics/documentation/asyncgraphics/graphic/hue(_:)), [tint](http://async.graphics/documentation/asyncgraphics/graphic/tinted(_:)), [channel mix](http://async.graphics/documentation/asyncgraphics/graphic/channelmix(red:green:blue:alpha:)), [blur](http://async.graphics/documentation/asyncgraphics/graphic/blurred(radius:)), [rainbow blur](http://async.graphics/documentation/asyncgraphics/graphic/rainbowblurredcircle(radius:angle:light:samplecount:options:)), [displace](http://async.graphics/documentation/asyncgraphics/graphic/displaced(with:offset:origin:placement:options:)), [edge](http://async.graphics/documentation/asyncgraphics/graphic/edge(amplitude:distance:options:)), [clamp](http://async.graphics/documentation/asyncgraphics/graphic/clamp(_:low:high:includealpha:options:)), [cross](http://async.graphics/documentation/asyncgraphics/graphic/cross(with:fraction:placement:options:)), [corner pin](http://async.graphics/documentation/asyncgraphics/graphic/cornerpinned(topleft:topright:bottomleft:bottomright:perspective:subdivisions:backgroundcolor:)), [chroma key](http://async.graphics/documentation/asyncgraphics/graphic/chromakey(color:parameters:options:)) a green screen.

## Metal

There is also the option to write high level [metal](http://async.graphics/documentation/asyncgraphics/graphic/metal(code:resolution:options:)) code in AsyncGraphics. No need to setup a pipeline.

## Install

```swift
.package(url: "https://github.com/heestand-xyz/AsyncGraphics", from: "0.9.4")
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

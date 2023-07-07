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

### Content

**Resources**:
[Image](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/image(named:)),
[Video](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/playvideo(url:loop:volume:)),
[Camera](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/camera(at:lens:quality:)),
[Maps](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/maps(type:latitude:longitude:span:resolution:mapoptions:options:)),
[Screen](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/screen(at:)),
[Text](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/text(_:font:center:horizontalalignment:verticalalignment:color:backgroundcolor:resolution:options:)),
[View](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/view(content:))

**Shapes**:
[Circle](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/circle(radius:center:color:backgroundcolor:resolution:options:)),
[Rectangle](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/rectangle(size:center:cornerradius:color:backgroundcolor:resolution:options:)),
[Arc](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/arc(angle:length:radius:center:color:backgroundcolor:resolution:options:)),
[Polygon](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/polygon(count:radius:center:rotation:cornerradius:color:backgroundcolor:resolution:options:)),
[Star](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/star(count:innerradius:outerradius:center:rotation:cornerradius:color:backgroundcolor:resolution:options:)),
[Line](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/line(leadingpoint:trailingpoint:linewidth:cap:color:backgroundcolor:resolution:options:))

**Solid**:
[Color](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/color(_:resolution:options:)),
[Gradient](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/gradient(direction:stops:center:scale:offset:extend:gamma:resolution:options:)),
[Noise](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/noise(offset:depth:scale:octaves:seed:resolution:options:)),
[Metal](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/metal(code:resolution:options:))

**Particles**:
[UV Particles](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/uvparticles(particlescale:particlecolor:backgroundcolor:resolution:samplecount:particleoptions:options:)),
[UV Color Particles](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/uvcolorparticles(with:particlescale:backgroundcolor:resolution:samplecount:particleoptions:options:))

### Effects

**Direct**:
[Blur](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/blurred(radius:)),
[Zoom Blur](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/blurredzoom(radius:center:samplecount:options:)),
[Angle Blur](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/blurredangle(radius:angle:samplecount:options:)),
[Circle Blur](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/blurredcircle(radius:samplecount:brightnessrange:saturationrange:light:options:)),
[Rainbow Blur](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/rainbowblurredcircle(radius:angle:light:samplecount:options:)),
[Random Blur](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/blurredrandom(radius:options:)),
[Channel Mix](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/channelmix(red:green:blue:alpha:)),
[Chroma Key](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/chromakey(color:parameters:options:)),
[Clamp](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/clamp(_:low:high:includealpha:options:)),
[Color Convert](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/colorconvert(_:channel:)),
[Hue](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/hue(_:)),
[Saturation](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/saturated(_:)),
[Monochrome](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/monochrome()),
[Tint](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/tinted(_:)),
[Corner Pin](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/cornerpinned(topleft:topright:bottomleft:bottomright:perspective:subdivisions:backgroundcolor:)),
[Edge](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/edge(amplitude:distance:options:)),
[Kaleidoscope](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/kaleidoscope(count:mirror:center:rotation:scale:options:)),
[Brightness](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/brightness(_:)),
[Contrast](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/contrast(_:)),
[Gamma](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/gamma(_:)),
[Inverted](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/inverted()),
[Opacity](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/opacity(_:)),
[Morph](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/morphedmaximum(size:)),
[Pixelate](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/pixelate(_:options:)),
[Quantize](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/quantize(_:options:)),
[Sharpen](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/sharpen(_:distance:options:)),
[Slope](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/slope(amplitude:origin:options:)),
[Threshold](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/threshold(_:options:)),
[Offset](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/offset(x:y:options:)),
[Rotate](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/rotated(_:options:)),
[Scale](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/scaled(_:options:)),
[Metal](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/metal(code:options:))

**Dual**:
[Blend](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/blended(with:blendingmode:placement:options:)),
[Cross](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/cross(with:fraction:placement:options:)),
[Displace](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/displaced(with:offset:origin:placement:options:)),
[Lookup](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/lookup(with:axis:samplecoordinate:options:)),
[Luma Blur](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/lumablurredbox(with:radius:lumagamma:samplecount:placement:options:)),
[Luma Rainbow Blur](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/lumarainbowblurredcircle(radius:angle:light:lumagamma:samplecount:placement:options:graphic:)),
[Luma Hue](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/lumahue(with:hue:lumagamma:)),
[Luma Saturation](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/lumasaturated(with:saturation:lumagamma:)),
[Luma Brightness](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/lumabrightness(with:brightness:lumagamma:placement:)),
[Luma Contrast](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/lumacontrast(with:contrast:lumagamma:placement:)),
[Luma Gamma](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/lumagamma(with:gamma:lumagamma:placement:)),
[Luma Translate](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/lumatranslated(with:x:y:lumagamma:placement:options:)),
[Luma Rotate](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/lumarotated(with:rotation:lumagamma:placement:options:)),
[Luma Scale](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/lumascaled(with:scale:lumagamma:placement:options:)),
[Remap](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/remap(options:graphic:)),
[Metal](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/metal(with:code:options:)-swift.method)

**Array**:
[HStack](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/hstacked(with:alignment:spacing:)),
[VStack](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/vstacked(with:alignment:spacing:)/),
[ZStack](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/zstacked(with:alignment:)),
[Layers](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/zblendstacked(with:alignment:)),
[Metal](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/metal(with:code:options:)-swift.type.method)

**Technical**:
[Add](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/add(with:)),
[Average](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/average(with:)),
[Bits](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/bits(_:)),
[Color Space](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/applycolorspace(_:)),
[Crop](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/crop(to:options:)),
[Inspect](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/inspect(scale:offset:borderwidth:borderopacity:borderfaderange:placement:containerresolution:contentresolution:transparencychecker:options:graphic:)),
[Polar](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/polar(radius:width:leadingangle:trailingangle:resolution:options:)),
[Reduce](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/reduce(by:axis:)),
[Resize](https://heestand-xyz.github.io/AsyncGraphics-Docs/documentation/asyncgraphics/graphic/resized(to:placement:method:)),
Coordinate Space,
LUT

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

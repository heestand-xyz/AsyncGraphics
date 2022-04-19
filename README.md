<img src="https://github.com/heestand-xyz/AsyncGraphics/blob/main/Assets/AsyncGraphics-Icon.png?raw=true" width="128px"/>

# AsyncGraphics

The core value type in **AsyncGraphics** is a `Graphic`.<br>
It's like an image, tho it can be used with various *async* methods.  

[DocC Documentation](http://async.graphics/documentation/AsyncGraphics)


## Swift Package

```swift
.package(url: "https://github.com/heestand-xyz/AsyncGraphics", from: "0.2.0")
```

```swift
import AsyncGraphics
```


## Graphic - Content

A `Graphic` can be created with static funcs e.g. `Graphic.image(named:)` or `Graphic.circle(size:radius:center:)`.

### Color

Colors are represented with the `PixelColor` type.<br>
`import PixelColor` to create custom colors with hex values.

```swift
static func color(_ color: PixelColor, size: CGSize) async throws -> Graphic
```

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

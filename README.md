# AsyncGraphics

The core value type in **AsyncGraphics** is a `Graphic`.<br>
It's like an image, tho it can be used with various *async* methods.  

## Swift Package

```swift
.package(url: "https://github.com/heestand-xyz/AsyncGraphics", from: "#.#.#")
```

## Graphic

A `Graphic` can be created with static funcs e.g. `Graphic.image(named:)` or `Graphic.circle(size:radius:center:)`.

```swift
import AsyncGraphics
```

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

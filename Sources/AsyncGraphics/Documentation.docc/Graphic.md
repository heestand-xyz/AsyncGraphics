# ``AsyncGraphics/Graphic``

A Graphic is like an image, but it's backed by a `MTLTexture`. 

## Topics

### Data

- ``image``
- ``texture``

### Metadata

- ``bits``
- ``colorSpace``

### Resolution

- ``width``
- ``height``
- ``size``
- ``resolution``

### Pixels

- ``firstPixelColor``
- ``averagePixelColor``
- ``pixelColors``
- ``channels``
- ``isPixelsEqual(to:)``

### Image

- ``image(_:)``
- ``image(named:in:)``

### Texture

- ``texture(_:)``

### Color

Create a graphic with a solid color.

- ``color(_:at:options:)``

### Rectangle

- ``rectangle(size:center:cornerRadius:color:backgroundColor:at:options:)``
- ``rectangle(frame:cornerRadius:color:backgroundColor:at:options:)``
- ``strokedRectangle(size:center:cornerRadius:lineWidth:color:backgroundColor:at:options:)``
- ``strokedRectangle(frame:cornerRadius:lineWidth:color:backgroundColor:at:options:)``

### Circle

- ``circle(radius:center:color:backgroundColor:at:options:)``
- ``strokedCircle(radius:center:lineWidth:color:backgroundColor:at:options:)``

### Noise

- ``noise(offset:depth:scale:octaves:seed:at:options:)``
- ``coloredNoise(offset:depth:scale:octaves:seed:at:options:)``
- ``randomNoise(seed:at:options:)``
- ``randomColoredNoise(seed:at:options:)``

### Particles

- ``uvParticles(particleScale:particleColor:particleOptions:backgroundColor:at:options:)``

### Transform

- ``translated(_:)``
- ``translated(x:y:)``
- ``rotated(_:)``
- ``scaled(_:)``
- ``scaled(x:y:)``

### Colorize

- ``monochrome()``
- ``saturated(_:)``
- ``hue(_:)``
- ``tinted(_:)``

### Blur

- ``blurred(radius:)``
- ``blurredBox(radius:sampleCount:)``
- ``blurredZoom(radius:center:sampleCount:)``
- ``blurredAngle(radius:angle:sampleCount:)``
- ``blurredRandom(radius:)``

### Blend

Use blending modes to combine two graphics.

- ``blended(with:blendingMode:placement:)``

### Invert

- ``inverted()``

### Displace

- ``displaced(with:offset:origin:placement:)``

### Cross

Fade two graphics by crossing them with opacity.

- ``cross(with:fraction:placement:)``

### Metal

Write metal shader code.

- ``metal(code:at:options:)``
- ``metal(code:)``
- ``metal(with:code:)``

### Resolution

Resize a graphic.

- ``resized(to:placement:)``
- ``resizedStretched(to:method:)``

### Bits

- ``bits(_:)``

### Reduce

- ``reduce(by:)``
- ``reduce(by:in:)``
- ``ReduceMethod``
- ``ReduceAxis``

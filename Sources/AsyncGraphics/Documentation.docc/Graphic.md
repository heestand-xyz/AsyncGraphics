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

### Resources

- ``image(_:)``
- ``image(named:in:)``
- ``texture(_:colorSpace:)``

### Color

Create a graphic with a solid color.

- ``color(_:at:)``

### Rectangle

- ``rectangle(size:center:cornerRadius:color:backgroundColor:at:)``
- ``rectangle(frame:cornerRadius:color:backgroundColor:at:)``
- ``strokedRectangle(size:center:cornerRadius:lineWidth:color:backgroundColor:at:)``
- ``strokedRectangle(frame:cornerRadius:lineWidth:color:backgroundColor:at:)``

### Circle

- ``circle(radius:center:color:backgroundColor:at:)``
- ``strokedCircle(radius:center:lineWidth:color:backgroundColor:at:)``

### Noise

- ``noise(offset:depth:scale:octaves:seed:at:)``
- ``coloredNoise(offset:depth:scale:octaves:seed:at:)``
- ``randomNoise(seed:at:)``
- ``randomColoredNoise(seed:at:)``

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

- ``metal(code:at:)``
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

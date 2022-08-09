# ``AsyncGraphics/Graphic``

A Graphic is like an image, but it's backed by a `MTLTexture`. 

## Topics

### ID

- ``id``

### Data

- ``image``
- ``texture``

### Metadata

- ``bits``
- ``colorSpace``

### Resolution

- ``resolution``
- ``width``
- ``height``

### Options

- ``ContentOptions``
- ``EffectOptions``

### Pixels

- ``firstPixelColor``
- ``averagePixelColor``
- ``pixelColors``
- ``channels``
- ``isPixelsEqual(to:)``

### Image

- ``image(_:)``
- ``image(named:in:)``
- ``image(url:)``

### Video

- ``videoFrames(url:)``
- ``videoData(with:fps:kbps:format:)``
- ``videoURL(with:fps:kbps:format:)``

### Texture

- ``texture(_:)``
- ``TextureError``

### Camera

- ``camera(_:device:preset:)``

### Color

Create a graphic with a solid color.

- ``color(_:resolution:options:)``

### Text

- ``text(_:font:center:horizontalAlignment:verticalAlignment:color:backgroundColor:resolution:options:)``
- ``TextFont``
- ``TextHorizontalAlignment``
- ``TextVerticalAlignment``

### Rectangle

- ``rectangle(size:center:cornerRadius:color:backgroundColor:resolution:options:)``
- ``rectangle(frame:cornerRadius:color:backgroundColor:resolution:options:)``
- ``strokedRectangle(size:center:cornerRadius:lineWidth:color:backgroundColor:resolution:options:)``
- ``strokedRectangle(frame:cornerRadius:lineWidth:color:backgroundColor:resolution:options:)``

### Circle

- ``circle(radius:center:color:backgroundColor:resolution:options:)``
- ``strokedCircle(radius:center:lineWidth:color:backgroundColor:resolution:options:)``

### Gradient

- ``gradient(direction:stops:position:scale:offset:extend:gamma:resolution:options:)``
- ``GradientDirection``
- ``GradientStop``
- ``GradientExtend``

### Noise

- ``noise(offset:depth:scale:octaves:seed:resolution:options:)``
- ``coloredNoise(offset:depth:scale:octaves:seed:resolution:options:)``
- ``randomNoise(seed:resolution:options:)``
- ``randomColoredNoise(seed:resolution:options:)``

### Particles

- ``uvParticles(particleScale:particleColor:backgroundColor:resolution:sampleCount:particleOptions:options:)``
- ``uvColorParticles(with:particleScale:backgroundColor:resolution:sampleCount:particleOptions:options:)``
- ``UVParticleSampleCount``
- ``UVParticleOptions``
- ``UVColorParticleOptions``

### Blend

Use blending modes to combine two or more graphics.

- ``blended(with:blendingMode:placement:)``
- ``blend(with:blendingMode:)``
- ``add(with:)``
- ``average(with:)``

### Transform

- ``translated(_:options:)``
- ``translated(x:y:options:)``
- ``rotated(_:options:)``
- ``scaled(_:options:)``
- ``scaled(x:y:options:)``

### Transpose

- ``mirroredHorizontally()``
- ``mirroredVertically()``
- ``rotatedLeft()``
- ``rotatedRight()``

### Stack

- ``hStack(with:alignment:spacing:padding:backgroundColor:resolution:)``
- ``vStack(with:alignment:spacing:padding:backgroundColor:resolution:)``
- ``HStackAlignment``
- ``VStackAlignment``

### Levels

- ``brightness(_:)``
- ``darkness(_:)``
- ``contrast(_:)``
- ``gamma(_:)``
- ``inverted()``
- ``smoothed()``
- ``opacity(_:)``
- ``exposureOffset(_:)``

### Colors

- ``monochrome()``
- ``saturated(_:)``
- ``hue(_:)``
- ``tinted(_:)``

### Channels

- ``channelMix(red:green:blue:alpha:)``
- ``ColorChannel``

### Blur

- ``blurred(radius:)``
- ``blurredBox(radius:sampleCount:options:)``
- ``blurredZoom(radius:center:sampleCount:options:)``
- ``blurredAngle(radius:angle:sampleCount:options:)``
- ``blurredRandom(radius:options:)``

### Displace

- ``displaced(with:offset:origin:placement:options:)``

### Slope

- ``slope(amplitude:options:)``

### Edge

- ``edge(amplitude:distance:options:)``
- ``coloredEdge(amplitude:distance:options:)``

### Cross

Fade two graphics by crossing them with opacity.

- ``cross(with:fraction:placement:)``

### Metal

Write metal shader code.

- ``metal(code:resolution:options:)``
- ``metal(code:options:)``
- ``metal(with:code:options:)-swift.method``
- ``metal(with:code:options:)-swift.type.method``
- ``SolidMetalError``
- ``DirectMetalError``
- ``DualMetalError``
- ``ArrayMetalError``

### UV

- ``uv(at:options:)``

### Resolution

Resize a graphic.

- ``resized(to:placement:)``
- ``resizedStretched(to:method:)``
- ``ResizeMethod``

### Reduce

- ``reduce(by:)``
- ``reduce(by:in:)``
- ``ReduceMethod``
- ``ReduceAxis``

### Bits

- ``bits(_:)``
- ``standardBit()``
- ``highBit()``

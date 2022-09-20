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

- ``videoDetails(url:)``
- ``VideoDetails``
- ``playVideo(url:loop:volume:)``
- ``importVideo(url:progress:)``
- ``ImportVideoFrameProgress``
- ``importVideoStream(url:)``
- ``exportVideoToData(with:fps:kbps:format:)``
- ``exportVideoToURL(with:fps:kbps:format:)``

### Texture

- ``texture(_:)``
- ``TextureError``

### Camera

- ``camera(_:device:preset:)``

### Screen

- ``screen(at:)``

### Maps

- ``maps(_:latitude:longitude:span:resolution:mapOptions:options:)``
- ``MapType``
- ``MapOptions``

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

### Polygon

- ``polygon(count:radius:center:rotation:cornerRadius:color:backgroundColor:resolution:options:)``

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

- ``blended(with:blendingMode:placement:options:)``
- ``blend(with:blendingMode:)``
- ``add(with:)``
- ``average(with:)``

### Transform

- ``translated(_:options:)``
- ``translated(x:y:options:)``
- ``rotated(_:options:)``
- ``scaled(_:options:)``
- ``scaled(x:y:options:)``

### Luma Transform

- ``lumaTranslated(with:translation:lumaGamma:placement:options:)``
- ``lumaTranslated(with:x:y:lumaGamma:placement:options:)``
- ``lumaRotated(with:rotation:lumaGamma:placement:options:)``
- ``lumaScaled(with:scale:lumaGamma:placement:options:)``
- ``lumaScaled(with:x:y:lumaGamma:placement:options:)``

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
- ``add(_:)``
- ``subtract(_:)``
- ``multiply(_:)``
- ``divide(_:)``

### Luma Levels

- ``lumaBrightness(with:brightness:lumaGamma:placement:)``
- ``lumaDarkness(with:darkness:lumaGamma:placement:)``
- ``lumaContrast(with:contrast:lumaGamma:placement:)``
- ``lumaGamma(with:gamma:lumaGamma:placement:)``
- ``lumaInverted(with:lumaGamma:placement:)``
- ``lumaSmoothed(with:lumaGamma:placement:)``
- ``lumaOpacity(with:opacity:lumaGamma:placement:)``
- ``lumaExposureOffset(with:offset:lumaGamma:placement:)``
- ``lumaAdd(with:value:lumaGamma:placement:)``
- ``lumaSubtract(with:value:lumaGamma:placement:)``
- ``lumaMultiply(with:value:lumaGamma:placement:)``
- ``lumaDivide(with:value:lumaGamma:placement:)``

### Colors

- ``monochrome()``
- ``saturated(_:)``
- ``hue(_:)``
- ``tinted(_:)``

### Luma Colors

- ``lumaMonochrome(with:lumaGamma:)``
- ``lumaMonochrome(with:lumaGamma:)``
- ``lumaSaturated(with:saturation:lumaGamma:)``
- ``lumaHue(with:hue:lumaGamma:)``
- ``lumaTinted(with:color:lumaGamma:)``

### Color Convert

- ``colorConvert(_:channel:)``
- ``ColorConversion``
- ``ColorConvertChannel``

### Threshold

- ``threshold(_:options:)``

### Quantize

- ``quantize(_:options:)``

### Channels

- ``channelMix(red:green:blue:alpha:)``
- ``alphaToLuminance()``
- ``luminanceToAlpha()``
- ``ColorChannel``

### Blur

- ``blurred(radius:)``
- ``blurredBox(radius:sampleCount:options:)``
- ``blurredZoom(radius:center:sampleCount:options:)``
- ``blurredAngle(radius:angle:sampleCount:options:)``
- ``blurredRandom(radius:options:)``

### Luma Blur

- ``lumaBlurredBox(with:radius:lumaGamma:sampleCount:placement:options:)``
- ``lumaBlurredZoom(with:radius:center:lumaGamma:sampleCount:placement:options:)``
-  ``lumaBlurredAngle(with:radius:angle:lumaGamma:sampleCount:placement:options:)``
- ``lumaBlurredRandom(with:radius:lumaGamma:placement:options:)``

### Rainbow Blur

- ``rainbowBlurredCircle(radius:angle:light:sampleCount:options:)``
- ``rainbowBlurredAngle(radius:angle:light:sampleCount:options:)``
- ``rainbowBlurredZoom(radius:center:light:sampleCount:options:)``

### Luma Rainbow Blur

- ``lumaRainbowBlurredCircle(with:radius:angle:light:lumaGamma:sampleCount:placement:options:)``
- ``lumaRainbowBlurredAngle(with:radius:angle:light:lumaGamma:sampleCount:placement:options:)``
- ``lumaRainbowBlurredZoom(with:radius:center:light:lumaGamma:sampleCount:placement:options:)``

### Displace

- ``displaced(with:offset:origin:placement:options:)``

### Slope

- ``slope(amplitude:origin:options:)``

### Edge

- ``edge(amplitude:distance:options:)``
- ``coloredEdge(amplitude:distance:options:)``

### Clamp

- ``clamp(_:low:high:includeAlpha:options:)``
- ``ClampType``

### Cross

Fade two graphics by crossing them with opacity.

- ``cross(with:fraction:placement:options:)``

### Corner Pin

- ``cornerPinned(topLeft:topRight:bottomLeft:bottomRight:perspective:subdivisions:backgroundColor:)``

### Chroma Key

- ``chromaKey(color:parameters:options:)``
- ``ChromaKeyParameters``

### Polar

- ``polar(radius:width:leadingAngle:trailingAngle:resolution:options:)``

### Morph

- ``morphedMinimum(size:)``
- ``morphedMaximum(size:)``

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

- ``uv(resolution:options:)``

### Resolution

Resize a graphic.

- ``resized(to:placement:)``
- ``resized(in:)``
- ``resizedStretched(to:method:)``
- ``resized(by:)``
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

### Color Space

- ``applyColorSpace(_:)``
- ``assignColorSpace(_:)``
- ``convertColorSpace(from:to:)``

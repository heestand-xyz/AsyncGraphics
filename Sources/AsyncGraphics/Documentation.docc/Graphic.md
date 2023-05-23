# ``AsyncGraphics/Graphic``

A Graphic is like an image, but it's backed by a `MTLTexture`. 

## Topics

### Resolution

- ``resolution``
- ``width``
- ``height``

### Texture

- ``texture``

### Metadata

- ``bits``
- ``colorSpace``

### Pixels

To edit colors `import PixelColor`, a swift package (a dependency of AsyncGraphics).

- ``firstPixelColor``
- ``averagePixelColor``
- ``pixelColors``
- ``channels``
- ``isPixelsEqual(to:)``
- ``pixels(_:options:)``
- ``pixel(x:y:options:)``
- ``pixel(u:v:options:)``

### Image

- ``image``
- ``imageWithTransparency``
- ``cgImage``
- ``ciImage``
- ``image(named:)``
- ``image(named:in:)``
- ``image(url:)``
- ``image(_:)-6435w``
- ``image(_:)-7tsh0``
- ``image(_:)-1mubl``
- ``pngData``

### Video

- ``videoDetails(url:)``
- ``VideoDetails``
- ``playVideo(url:loop:volume:)``
- ``importVideo(url:progress:)``
- ``ImportVideoFrameProgress``
- ``importVideoStream(url:)``
- ``importVideoFrame(at:url:info:)``
- ``exportVideoToData(with:fps:kbps:format:)``
- ``exportVideoToURL(with:fps:kbps:format:)``
- ``processVideo(url:)``

### Texture

- ``texture(_:)``
- ``TextureError``

### Buffer

- ``pixelBuffer``
- ``sampleBuffer``
- ``pixelBuffer(_:)``
- ``sampleBuffer(_:)``
- ``BufferError``

### View

SwiftUI to Graphic

- ``view(content:)``
- ``view(resolution:content:)``

### Graph

- ``graph(resolution:renderer:graph:)``

### Camera

- ``Camera``
- ``camera(with:)``
- ``camera(at:lens:quality:)``
- ``camera(device:quality:)``
- ``camera(_:device:preset:)``
- ``CameraPosition``

### Screen

- ``screen(at:)``

### Maps

- ``maps(type:latitude:longitude:span:resolution:mapOptions:options:)``
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

### Arc

- ``arc(angle:length:radius:center:color:backgroundColor:resolution:options:)``
- ``strokedArc(angle:length:radius:center:lineWidth:color:backgroundColor:resolution:options:)``

### Star

- ``star(count:innerRadius:outerRadius:center:rotation:cornerRadius:color:backgroundColor:resolution:options:)``

### Line

- ``line(leadingPoint:trailingPoint:lineWidth:cap:color:backgroundColor:resolution:options:)``
- ``LineCap``

### Gradient

- ``gradient(direction:stops:center:scale:offset:extend:gamma:resolution:options:)``
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

- ``blended(blendingMode:placement:options:graphic:)``
- ``blended(with:blendingMode:placement:options:)``
- ``blend(with:blendingMode:)``
- ``add(with:)``
- ``average(with:)``
- ``mask(placement:options:foreground:background:mask:)``
- ``mask(foreground:background:mask:placement:options:)``

### Transform

- ``offset(_:options:)``
- ``translated(_:options:)``
- ``offset(x:y:options:)``
- ``translated(x:y:options:)``
- ``rotated(_:options:)``
- ``scaled(_:options:)``
- ``sized(width:height:options:)``
- ``sized(_:options:)``
- ``transformed(translation:rotation:scale:size:options:)``

### Luma Transform

- ``lumaOffset(_:lumaGamma:placement:options:graphic:)``
- ``lumaTranslated(with:translation:lumaGamma:placement:options:)``
- ``lumaOffset(x:y:lumaGamma:placement:options:graphic:)``
- ``lumaTranslated(with:x:y:lumaGamma:placement:options:)``
- ``lumaRotated(rotation:lumaGamma:placement:options:graphic:)``
- ``lumaRotated(with:rotation:lumaGamma:placement:options:)``
- ``lumaScaled(scale:lumaGamma:placement:options:graphic:)``
- ``lumaScaled(with:scale:lumaGamma:placement:options:)``
- ``lumaScaled(x:y:lumaGamma:placement:options:graphic:)``
- ``lumaScaled(with:x:y:lumaGamma:placement:options:)``

### Transform with Blend

- ``transformBlended(blendingMode:placement:translation:rotation:scale:size:options:graphic:)``
- ``transformBlended(with:blendingMode:placement:translation:rotation:scale:size:options:)``

### Mirror

- ``mirroredHorizontally()``
- ``mirroredVertically()``

### Rotate

- ``rotatedLeft()``
- ``rotatedRight()``

### Stack

- ``hStacked(with:alignment:spacing:)``
- ``hStackedFixed(with:alignment:spacing:padding:backgroundColor:resolution:)``
- ``hStack(with:alignment:spacing:padding:backgroundColor:resolution:)``
- ``vStacked(with:alignment:spacing:)``
- ``vStackedFixed(with:alignment:spacing:padding:backgroundColor:resolution:)``
- ``vStack(with:alignment:spacing:padding:backgroundColor:resolution:)``
- ``zStacked(with:alignment:)``
- ``zBlendStacked(with:alignment:)``
- ``HStackAlignment``
- ``VStackAlignment``
- ``ZStackAlignment``
- ``BlendedGraphic``

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
- ``levels(brightness:darkness:contrast:gamma:invert:smooth:opacity:offset:)``

### Luma Levels

- ``lumaBrightness(brightness:lumaGamma:placement:graphic:)``
- ``lumaBrightness(with:brightness:lumaGamma:placement:)``
- ``lumaDarkness(darkness:lumaGamma:placement:graphic:)``
- ``lumaDarkness(with:darkness:lumaGamma:placement:)``
- ``lumaContrast(contrast:lumaGamma:placement:graphic:)``
- ``lumaContrast(with:contrast:lumaGamma:placement:)``
- ``lumaGamma(gamma:lumaGamma:placement:graphic:)``
- ``lumaGamma(with:gamma:lumaGamma:placement:)``
- ``lumaInverted(lumaGamma:placement:graphic:)``
- ``lumaInverted(with:lumaGamma:placement:)``
- ``lumaSmoothed(lumaGamma:placement:graphic:)``
- ``lumaSmoothed(with:lumaGamma:placement:)``
- ``lumaOpacity(opacity:lumaGamma:placement:graphic:)``
- ``lumaOpacity(with:opacity:lumaGamma:placement:)``
- ``lumaExposureOffset(offset:lumaGamma:placement:graphic:)``
- ``lumaExposureOffset(with:offset:lumaGamma:placement:)``
- ``lumaAdd(value:lumaGamma:placement:graphic:)``
- ``lumaAdd(with:value:lumaGamma:placement:)``
- ``lumaSubtract(value:lumaGamma:placement:graphic:)``
- ``lumaSubtract(with:value:lumaGamma:placement:)``
- ``lumaMultiply(value:lumaGamma:placement:graphic:)``
- ``lumaMultiply(with:value:lumaGamma:placement:)``
- ``lumaDivide(value:lumaGamma:placement:graphic:)``
- ``lumaDivide(with:value:lumaGamma:placement:)``

### Colors

- ``monochrome()``
- ``saturated(_:)``
- ``hue(_:)``
- ``tinted(_:)``

### Luma Colors

- ``lumaMonochrome(lumaGamma:graphic:)``
- ``lumaMonochrome(with:lumaGamma:)``
- ``lumaSaturated(saturation:lumaGamma:graphic:)``
- ``lumaSaturated(with:saturation:lumaGamma:)``
- ``lumaHue(hue:lumaGamma:graphic:)``
- ``lumaHue(with:hue:lumaGamma:)``
- ``lumaTinted(color:lumaGamma:graphic:)``
- ``lumaTinted(with:color:lumaGamma:)``

### Color Convert

- ``colorConvert(_:channel:)``
- ``ColorConversion``
- ``ColorConvertChannel``

### Threshold

- ``threshold(_:options:)``

### Quantize

- ``quantize(_:options:)``

### Lookup

- ``lookup(axis:sampleCoordinate:options:graphic:)``
- ``lookup(with:axis:sampleCoordinate:options:)``
- ``LookupAxis``

### Channels

- ``channelMix(red:green:blue:alpha:)``
- ``alphaToLuminance()``
- ``alphaToLuminanceWithAlpha()``
- ``luminanceToAlpha()``
- ``ColorChannel``

### Blur

- ``blurred(radius:)``
- ``blurredBox(radius:sampleCount:options:)``
- ``blurredCircle(radius:sampleCount:brightnessRange:saturationRange:light:options:)``
- ``blurredZoom(radius:center:sampleCount:options:)``
- ``blurredAngle(radius:angle:sampleCount:options:)``
- ``blurredRandom(radius:options:)``

### Luma Blur

- ``lumaBlurredBox(radius:lumaGamma:sampleCount:placement:options:graphic:)``
- ``lumaBlurredBox(with:radius:lumaGamma:sampleCount:placement:options:)``
- ``lumaBlurredZoom(radius:center:lumaGamma:sampleCount:placement:options:graphic:)``
- ``lumaBlurredZoom(with:radius:center:lumaGamma:sampleCount:placement:options:)``
- ``lumaBlurredAngle(radius:angle:lumaGamma:sampleCount:placement:options:graphic:)``
- ``lumaBlurredAngle(with:radius:angle:lumaGamma:sampleCount:placement:options:)``
- ``lumaBlurredRandom(radius:lumaGamma:placement:options:graphic:)``
- ``lumaBlurredRandom(with:radius:lumaGamma:placement:options:)``

### Rainbow Blur

- ``rainbowBlurredCircle(radius:angle:light:sampleCount:options:)``
- ``rainbowBlurredAngle(radius:angle:light:sampleCount:options:)``
- ``rainbowBlurredZoom(radius:center:light:sampleCount:options:)``

### Luma Rainbow Blur

- ``lumaRainbowBlurredCircle(radius:angle:light:lumaGamma:sampleCount:placement:options:graphic:)``
- ``lumaRainbowBlurredCircle(with:radius:angle:light:lumaGamma:sampleCount:placement:options:)``
- ``lumaRainbowBlurredAngle(radius:angle:light:lumaGamma:sampleCount:placement:options:graphic:)``
- ``lumaRainbowBlurredAngle(with:radius:angle:light:lumaGamma:sampleCount:placement:options:)``
- ``lumaRainbowBlurredZoom(radius:center:light:lumaGamma:sampleCount:placement:options:graphic:)``
- ``lumaRainbowBlurredZoom(with:radius:center:light:lumaGamma:sampleCount:placement:options:)``

### Pixelate

- ``pixelate(_:options:)``

### Displace

- ``displaced(offset:origin:placement:options:graphic:)``
- ``displaced(with:offset:origin:placement:options:)``

### Slope

- ``slope(amplitude:origin:options:)``

### Edge

- ``edge(amplitude:distance:options:)``
- ``coloredEdge(amplitude:distance:options:)``

### Sharpen

- ``sharpen(_:distance:options:)``

### Kaleidoscope

- ``kaleidoscope(count:mirror:center:rotation:scale:options:)``

### Clamp

- ``clamp(_:low:high:includeAlpha:options:)``
- ``ClampType``

### Cross

Fade two graphics by crossing them with opacity.

- ``cross(fraction:placement:options:graphic:)``
- ``cross(with:fraction:placement:options:)``

### Crop

- ``crop(to:options:)``
- ``column(_:options:)``
- ``column(u:options:)``
- ``row(_:options:)``
- ``row(v:options:)``

### Padding

- ``padding(on:_:options:)``
- ``EdgeInsets``

### Corner Pin

- ``cornerPinned(topLeft:topRight:bottomLeft:bottomRight:perspective:subdivisions:backgroundColor:)``

### Chroma Key

- ``chromaKey(color:parameters:options:)``
- ``ChromaKeyParameters``

### Remap

- ``remap(options:graphic:)``

### Polar

- ``polar(radius:width:leadingAngle:trailingAngle:resolution:options:)``

### Morph

- ``morphedMinimum(size:)``
- ``morphedMaximum(size:)``

### Metal

Write metal shader code.

- ``metal(code:resolution:options:)``
- ``metal(code:options:)``
- ``metal(code:options:graphic:)``
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

- ``resized(to:placement:method:)``
- ``resizedStretched(to:method:)``
- ``resized(in:options:)``
- ``resized(to:placement:options:)``
- ``resized(by:)``
- ``ResizeMethod``

### Reduce

- ``reduce(by:)``
- ``reduce(by:axis:)``
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

### Inspect

- ``inspect(scale:offset:borderWidth:borderOpacity:borderFadeRange:placement:containerResolution:contentResolution:transparencyChecker:options:graphic:)``

### Options

- ``ContentOptions``
- ``EffectOptions``

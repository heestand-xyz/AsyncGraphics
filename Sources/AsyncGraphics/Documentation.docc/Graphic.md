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

- ``id``
- ``bits``
- ``colorSpace``

### Pixels

To edit colors `import PixelColor`, a swift package (a dependency of AsyncGraphics).

- ``firstPixelColor``
- ``averagePixelColor``
- ``pixelColors``
- ``isPixelsEqual(to:)``
- ``pixels(_:options:)``
- ``pixel(x:y:options:)``
- ``pixel(u:v:options:)``

### Channels

- ``channels``
- ``channels8``
- ``channels16``
- ``channels32``
- ``channels(_:resolution:)-5dtx6``
- ``channels(_:resolution:)-6011k``
- ``channels(_:resolution:)-6011k``
- ``channels(pointer:resolution:)-1mynx``
- ``channels(pointer:resolution:)-5svpm``
- ``channels(pointer:resolution:)-5svpm``

## Content

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
- ``xdrImage``
- ``writeImage(to:xdr:)``
- ``isRAWImage(url:)``
- ``rawImage(url:)-1dcqq``
- ``rawImage(url:)-8w81k``

### Video

- ``videoDetails(url:)``
- ``VideoDetails``
- ``playVideo(url:loop:volume:)``
- ``importVideo(url:progress:)``
- ``ImportVideoFrameProgress``
- ``importVideoStream(url:)``
- ``importVideoFrame(at:url:info:)``
- ``exportVideoToURL(with:fps:kbps:format:codec:)``
- ``exportVideoToData(with:fps:kbps:format:codec:)``
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
- ``view(resolution:alignment:content:)``

### Resolution

Resize a graphic.

- ``resized(to:placement:method:)``
- ``resizedStretched(to:method:)``
- ``resized(in:options:)``
- ``resized(to:placement:options:)``
- ``resized(by:)``
- ``ResizeMethod``

### Graph

- ``graph(resolution:renderer:graph:)``

### Camera

- ``Camera``
- ``camera(with:)``
- ``camera(at:lens:quality:)``
- ``camera(device:quality:)``
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

- ``text(_:font:position:horizontalAlignment:verticalAlignment:color:backgroundColor:resolution:options:)``
- ``TextFont``
- ``TextHorizontalAlignment``
- ``TextVerticalAlignment``

### Rectangle

- ``rectangle(size:position:cornerRadius:color:backgroundColor:resolution:options:)``
- ``rectangle(frame:cornerRadius:color:backgroundColor:resolution:options:)``
- ``strokedRectangle(size:position:cornerRadius:lineWidth:color:backgroundColor:resolution:options:)``
- ``strokedRectangle(frame:cornerRadius:lineWidth:color:backgroundColor:resolution:options:)``

### Circle

- ``circle(radius:position:color:backgroundColor:resolution:options:)``
- ``strokedCircle(radius:position:lineWidth:color:backgroundColor:resolution:options:)``

### Polygon

- ``polygon(count:radius:position:rotation:cornerRadius:color:backgroundColor:resolution:options:)``

### Arc

- ``arc(angle:length:radius:position:color:backgroundColor:resolution:options:)``
- ``strokedArc(angle:length:radius:position:lineWidth:color:backgroundColor:resolution:options:)``

### Star

- ``star(count:innerRadius:outerRadius:position:rotation:cornerRadius:color:backgroundColor:resolution:options:)``

### Line

- ``line(leadingPoint:trailingPoint:lineWidth:cap:color:backgroundColor:resolution:options:)``
- ``LineCap``

### Sample Line

- ``sampleLine(with:form:to:fromAngle:toAngle:count:blendingMode:tintColor:backgroundColor:resolution:options:)``
- ``sampleLine(with:form:to:fromAngle:toAngle:sampleDistance:blendingMode:tintColor:backgroundColor:resolution:options:)``

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

## Effects

### Blend

Use blending modes to combine two or more graphics.

- ``blend(with:blendingMode:)``
- ``blend(with:blendingMode:placement:alignment:options:)``
- ``blended(with:blendingMode:placement:alignment:options:)``
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

- ``lumaOffset(with:translation:lumaGamma:placement:options:)``
- ``lumaOffset(with:x:y:lumaGamma:placement:options:)``
- ``lumaTranslated(with:translation:lumaGamma:placement:options:)``
- ``lumaTranslated(with:x:y:lumaGamma:placement:options:)``
- ``lumaRotated(with:rotation:lumaGamma:placement:options:)``
- ``lumaScaled(with:scale:lumaGamma:placement:options:)``
- ``lumaScaled(with:x:y:lumaGamma:placement:options:)``

### Transform with Blend

- ``transformBlended(with:blendingMode:placement:alignment:translation:rotation:scale:size:options:)``

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

- ``lumaBrightness(with:brightness:lumaGamma:placement:options:)``
- ``lumaDarkness(with:darkness:lumaGamma:placement:options:)``
- ``lumaContrast(with:contrast:lumaGamma:placement:options:)``
- ``lumaGamma(with:gamma:lumaGamma:placement:options:)``
- ``lumaInverted(with:lumaGamma:placement:options:)``
- ``lumaSmoothed(with:lumaGamma:placement:options:)``
- ``lumaOpacity(with:opacity:lumaGamma:placement:options:)``
- ``lumaExposureOffset(with:offset:lumaGamma:placement:options:)``
- ``lumaAdd(with:value:lumaGamma:placement:options:)``
- ``lumaSubtract(with:value:lumaGamma:placement:options:)``
- ``lumaMultiply(with:value:lumaGamma:placement:options:)``
- ``lumaDivide(with:value:lumaGamma:placement:options:)``

### Color Shift

- ``monochrome()``
- ``saturated(_:)``
- ``hue(_:)``
- ``tinted(_:)``
- ``colorMap(from:to:options:)``

### Luma Color Shift

- ``lumaMonochrome(with:lumaGamma:placement:options:)``
- ``lumaSaturated(with:saturation:lumaGamma:placement:options:)``
- ``lumaHue(with:hue:lumaGamma:placement:options:)``
- ``lumaTinted(with:color:lumaGamma:placement:options:)``

### Color Convert

- ``colorConvert(_:channel:)``
- ``ColorConversion``
- ``ColorConvertChannel``

### Threshold

- ``threshold(_:color:backgroundColor:options:)``

### Quantize

- ``quantize(_:options:)``

### Lookup

- ``lookup(with:axis:sampleCoordinate:options:)``
- ``LookupAxis``

### Gradient Lookup

- ``gradientLookup(stops:gamma:options:)``

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
- ``blurredZoom(radius:position:sampleCount:options:)``
- ``blurredAngle(radius:angle:sampleCount:options:)``
- ``blurredRandom(radius:options:)``

### Luma Blur

- ``lumaBlurredBox(with:radius:lumaGamma:sampleCount:placement:options:)``
- ``lumaBlurredZoom(with:radius:position:lumaGamma:sampleCount:placement:options:)``
- ``lumaBlurredAngle(with:radius:angle:lumaGamma:sampleCount:placement:options:)``
- ``lumaBlurredRandom(with:radius:lumaGamma:placement:options:)``

### Rainbow Blur

- ``rainbowBlurredCircle(radius:angle:light:sampleCount:options:)``
- ``rainbowBlurredAngle(radius:angle:light:sampleCount:options:)``
- ``rainbowBlurredZoom(radius:position:light:sampleCount:options:)``

### Luma Rainbow Blur

- ``lumaRainbowBlurredCircle(with:radius:angle:light:lumaGamma:sampleCount:placement:options:)``
- ``lumaRainbowBlurredAngle(with:radius:angle:light:lumaGamma:sampleCount:placement:options:)``
- ``lumaRainbowBlurredZoom(with:radius:position:light:lumaGamma:sampleCount:placement:options:)``

### Pixelate

- ``pixelate(_:options:)``

### Displace

- ``displaced(with:offset:origin:placement:options:)``

### Slope

- ``slope(amplitude:origin:options:)``

### Edge

- ``edge(amplitude:distance:isTransparent:options:)``
- ``coloredEdge(amplitude:distance:isTransparent:options:)``

### Sharpen

- ``sharpen(_:distance:options:)``

### Kaleidoscope

- ``kaleidoscope(count:mirror:position:rotation:scale:options:)``

### Clamp

- ``clamp(_:low:high:includeAlpha:options:)``
- ``ClampType``

### Cross

Fade two graphics by crossing them with opacity.

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

### Person Segmentation

- ``personSegmentation()``
- ``personSegmentationMask()``

### Remap

- ``remap(with:options:)``

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

- ``

### Reduce

- ``reduce(by:)``
- ``reduce(by:axis:)``
- ``ReduceMethod``
- ``ReduceAxis``

### LUTs

- ``readLUT(url:layout:)``
- ``readLUT(data:format:layout:)``
- ``readLUT(named:format:layout:)``
- ``readLUT(named:in:format:layout:)``

- ``writeLUT(layout:)``

- ``applyLUT(with:layout:)``
- ``applyLUT(url:)``
- ``applyLUT(named:format:)``
- ``applyLUT(named:in:format:)``

- ``sizeOfLUT()``
- ``sizeOfLUT(url:)``
- ``sizeOfLUT(data:format:)``
- ``sizeOfLUT(named:format:)``
- ``sizeOfLUT(named:in:format:)``

- ``layoutOfLUT()``
- ``idealLayoutOfLUT(size:)``
- ``idealLayoutOfLUT(url:)``
- ``idealLayoutOfLUT(data:format:)``
- ``idealLayoutOfLUT(named:format:)``
- ``idealLayoutOfLUT(named:in:format:)``

- ``sampleOfLUT(at:layout:)``

- ``identityLUT(size:layout:options:)``

- ``LUTLayout``
- ``LUTFormat``
- ``LUTError``

### Bits

- ``bits(_:)``
- ``standardBit()``
- ``highBit()``

### Color Space

- ``applyColorSpace(_:)``
- ``assignColorSpace(_:)``
- ``convertColorSpace(from:to:)``

### Coordinate Space

- ``coordinateSpace(_:rotation:fraction:options:)``
- ``CoordinateSpaceConversion``

### Inspect

- ``inspect(scale:offset:borderWidth:borderOpacity:borderFadeRange:placement:containerResolution:contentResolution:checkerTransparency:checkerSize:checkerOpacity:options:)``

### Options

- ``ContentOptions``
- ``EffectOptions``

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
- ``isPixelsEqual(to:threshold:)``
- ``pixels(_:options:)``
- ``pixel(x:y:options:)``
- ``pixel(u:v:options:)``
- ``subPixel(u:v:)``

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
- ``imageForSwiftUI``
- ``rawImage``
- ``sendableImage``
- ``imageWithTransparency``
- ``sendableImageWithTransparency``
- ``cgImage``
- ``ciImage``
- ``image(named:options:)``
- ``image(named:in:options:)``
- ``image(url:options:)``
- ``image(data:options:)``
- ``image(sendable:options:)``
- ``image(_:options:)-1k0fx``
- ``image(_:options:)-78gjp``
- ``image(_:options:)-6lxrv``
- ``pngData``
- ``xdrImage``
- ``sendableXDRImage``
- ``writeImage(to:xdr:)``
- ``isRAWImage(url:)``
- ``rawImage(url:)-1dcqq``
- ``rawImage(url:)-8w81k``
- ``ImageOptions``

### Stereoscopic

- ``isStereoscopic(image:)``
- ``isStereoscopic(source:)``
- ``isStereoscopicImage(url:)``
- ``stereoscopicImages(url:)``
- ``stereoscopicImages(image:)``
- ``stereoscopicImages(source:)``
- ``stereoscopicGraphics(url:)``
- ``stereoscopicGraphics(image:)``
- ``stereoscopicGraphics(source:)``

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
- ``resized(to:placement:interpolation:options:)``
- ``resized(by:)``
- ``ResizeMethod``
- ``ResolutionInterpolation``

### Graph

- ``graph(resolution:renderer:graph:)``

### Map

- ``mapImage(_:)``
- ``mapTexture(_:)``

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

### Rectangle

- ``rectangle(size:position:cornerRadius:color:backgroundColor:resolution:tile:options:)``
- ``rectangle(frame:cornerRadius:color:backgroundColor:resolution:tile:options:)``
- ``strokedRectangle(size:position:cornerRadius:lineWidth:color:backgroundColor:resolution:tile:options:)``
- ``strokedRectangle(frame:cornerRadius:lineWidth:color:backgroundColor:resolution:tile:options:)``

### Circle

- ``circle(radius:position:color:backgroundColor:resolution:tile:options:)``
- ``strokedCircle(radius:position:lineWidth:color:backgroundColor:resolution:tile:options:)``

### Polygon

- ``polygon(count:radius:position:rotation:cornerRadius:color:backgroundColor:resolution:tile:options:)``

### Arc

- ``arc(angle:length:radius:position:color:backgroundColor:resolution:tile:options:)``
- ``strokedArc(angle:length:radius:position:lineWidth:color:backgroundColor:resolution:tile:options:)``

### Star

- ``star(count:innerRadius:outerRadius:position:rotation:cornerRadius:color:backgroundColor:resolution:tile:options:)``

### Line

- ``line(leadingPoint:trailingPoint:lineWidth:cap:color:backgroundColor:resolution:tile:options:)``
- ``line(from:to:lineWidth:cap:color:backgroundColor:resolution:tile:options:)``
- ``LineCap``

### Sample Line

- ``sampleLine(with:form:to:fromAngle:toAngle:count:blendingMode:tintColor:backgroundColor:resolution:options:)``
- ``sampleLine(with:form:to:fromAngle:toAngle:sampleDistance:blendingMode:tintColor:backgroundColor:resolution:options:)``

### Gradient

- ``gradient(direction:stops:position:scale:offset:extend:gamma:resolution:tile:options:)``
- ``GradientDirection``
- ``GradientStop``
- ``GradientExtend``

### Noise

- ``noise(offset:depth:scale:octaves:seed:resolution:tile:options:)``
- ``coloredNoise(offset:depth:scale:octaves:seed:resolution:tile:options:)``
- ``randomNoise(seed:resolution:tile:options:)``
- ``randomColoredNoise(seed:resolution:tile:options:)``

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
- ``frameBlend(with:blendingMode:placement:alignment:frame:rotation:options:)``
- ``frameBlended(with:blendingMode:placement:alignment:frame:rotation:options:)``
- ``transformBlend(with:blendingMode:placement:alignment:translation:rotation:scale:size:options:)``
- ``transformBlended(with:blendingMode:placement:alignment:translation:rotation:scale:size:options:)``
- ``transformBlend(with:blendingMode:placement:alignment:offset:rotation:scale:size:options:)``
- ``transformBlended(with:blendingMode:placement:alignment:offset:rotation:scale:size:options:)``
- ``add(with:)``
- ``average(with:)``
- ``mask(foreground:background:mask:placement:options:)``
- ``BlendMode``
- ``MultiBlendMode``

### Transform

- ``offset(_:options:)``
- ``offset(x:y:options:)``
- ``rotated(_:options:)``
- ``scaled(_:options:)``
- ``sized(width:height:options:)``
- ``sized(_:options:)``
- ``transformed(translation:rotation:scale:size:options:)``

### Luma Transform

- ``lumaOffset(with:translation:lumaGamma:placement:options:)``
- ``lumaOffset(with:x:y:lumaGamma:placement:options:)``
- ``lumaRotated(with:rotation:lumaGamma:placement:options:)``
- ``lumaScaled(with:scale:lumaGamma:placement:options:)``
- ``lumaScaled(with:x:y:lumaGamma:placement:options:)``

### Mirror

- ``mirroredHorizontally(options:)``
- ``mirroredVertically(options:)``

### Rotate

- ``rotatedLeft(options:)``
- ``rotatedRight(options:)``

### Stack

- ``hStacked(with:alignment:spacing:options:)``
- ``hStackedFixed(with:alignment:spacing:padding:backgroundColor:resolution:options:)``
- ``hStack(with:alignment:spacing:padding:backgroundColor:resolution:options:)``
- ``vStacked(with:alignment:spacing:options:)``
- ``vStackedFixed(with:alignment:spacing:padding:backgroundColor:resolution:options:)``
- ``vStack(with:alignment:spacing:padding:backgroundColor:resolution:options:)``
- ``zStacked(with:alignment:options:)``
- ``zBlendStacked(with:alignment:options:)``
- ``HStackAlignment``
- ``VStackAlignment``
- ``ZStackAlignment``
- ``BlendedGraphic``

### Range

- ``range(referenceLow:referenceHigh:targetLow:targetHigh:includeAlpha:options:)``

### Levels

- ``brightness(_:options:)``
- ``darkness(_:options:)``
- ``contrast(_:options:)``
- ``gamma(_:options:)``
- ``inverted(options:)``
- ``smoothed(options:)``
- ``opacity(_:options:)``
- ``exposureOffset(_:options:)``
- ``add(_:options:)``
- ``subtract(_:options:)``
- ``multiply(_:options:)``
- ``divide(_:options:)``
- ``levels(brightness:darkness:contrast:gamma:invert:smooth:opacity:offset:options:)``

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

- ``monochrome(options:)``
- ``saturated(_:options:)``
- ``hue(_:options:)``
- ``tinted(_:options:)``
- ``colorMap(from:to:options:)``

### Luma Color Shift

- ``lumaMonochrome(with:lumaGamma:placement:options:)``
- ``lumaSaturated(with:saturation:lumaGamma:placement:options:)``
- ``lumaHue(with:hue:lumaGamma:placement:options:)``
- ``lumaTinted(with:color:lumaGamma:placement:options:)``

### Color Convert

- ``colorConvert(_:channel:options:)``
- ``ColorConversion``
- ``ColorConvertChannel``

### Sepia

- ``sepia(color:gamma:options:)``

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

- ``channelMix(red:green:blue:alpha:options:)``
- ``alphaToLuminance()``
- ``alphaToLuminanceWithAlpha()``
- ``luminanceToAlpha()``
- ``luminanceToAlphaWithColor()``
- ``ColorChannel``

### Blur

- ``blurred(radius:)``
- ``blurredBox(radius:sampleCount:options:)``
- ``blurredCircle(radius:sampleCount:brightnessRange:saturationRange:light:options:)``
- ``blurredZoom(radius:position:sampleCount:options:)``
- ``blurredAngle(radius:angle:sampleCount:options:)``
- ``blurredRandom(radius:options:)``
- ``blurredLayered(radius:layerCount:options:)``
- ``blurredLayeredSinglePass(radius:options:)``
- ``BlurType``

### Luma Blur

- ``lumaBlurredBox(with:radius:lumaGamma:sampleCount:placement:options:)``
- ``lumaBlurredZoom(with:radius:position:lumaGamma:sampleCount:placement:options:)``
- ``lumaBlurredAngle(with:radius:angle:lumaGamma:sampleCount:placement:options:)``
- ``lumaBlurredRandom(with:radius:lumaGamma:placement:options:)``
- ``lumaBlurredLayered(with:radius:lumaGamma:layerCount:placement:options:)``
- ``lumaBlurredLayeredSinglePass(with:radius:lumaGamma:placement:options:)``
- ``LumaBlurType``

### Rainbow Blur

- ``rainbowBlurredCircle(radius:angle:light:sampleCount:options:)``
- ``rainbowBlurredAngle(radius:angle:light:sampleCount:options:)``
- ``rainbowBlurredZoom(radius:position:light:sampleCount:options:)``
- ``RainbowBlurType``

### Luma Rainbow Blur

- ``lumaRainbowBlurredCircle(with:radius:angle:light:lumaGamma:sampleCount:placement:options:)``
- ``lumaRainbowBlurredAngle(with:radius:angle:light:lumaGamma:sampleCount:placement:options:)``
- ``lumaRainbowBlurredZoom(with:radius:position:light:lumaGamma:sampleCount:placement:options:)``
- ``LumaRainbowBlurType``

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

- ``cornerPinned(topLeft:topRight:bottomLeft:bottomRight:perspective:subdivisions:backgroundColor:options:)``

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
- ``MorphType``

### Face Detection

- ``detectFaces()``
- ``FaceDetection``

### Flood Fill

- ``floodFillAccurately(position:threshold:color:backgroundColor:levels:maximumIterations:options:loop:)``
- ``floodFillRecursively(position:threshold:color:backgroundColor:levels:maximumIterations:options:loop:)``
- ``floodFillPrecisely(position:threshold:color:backgroundColor:options:)``
- ``floodFillPrecisely(pixels:resolution:position:threshold:color:backgroundColor:)``

### Metal

Write metal shader code.

- ``metal(code:resolution:options:)-swift.method``
- ``metal(code:resolution:options:)-swift.type.method``
- ``metal(with:code:options:)-swift.method``
- ``metal(with:code:options:)-swift.type.method``
- ``rawMetal(with:code:functionName:uniformsBuffer:resolution:options:)``
- ``SolidMetalError``
- ``DirectMetalError``
- ``DualMetalError``
- ``ArrayMetalError``

### UV

- ``uv(resolution:options:)``

### Reduce

- ``reduce(by:)``
- ``reduce(by:axis:)``
- ``reduceToRow(by:)``
- ``reduceToColumn(by:)``
- ``ReduceMethod``
- ``ReduceAxis``

### LUTs

- ``readLUT(url:layout:)``
- ``readLUT(data:format:layout:)``
- ``readLUT(named:format:layout:)``
- ``readLUT(named:in:format:layout:)``

- ``writeLUT(layout:)``

- ``applyLUT(with:layout:options:)``
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

- ``withBits(_:options:)``
- ``bits(_:)``
- ``Bits-swift.enum``

### Color Space

- ``applyColorSpace(_:)``
- ``assignColorSpace(_:)``
- ``convertColorSpace(from:to:)``

### Coordinate Space

- ``coordinateSpace(_:rotation:fraction:options:)``
- ``CoordinateSpaceConversion``

### Inspect

- ``inspect(scale:offset:borderWidth:borderOpacity:borderFadeRange:placement:containerResolution:contentResolution:checkerTransparency:checkerSize:checkerOpacity:options:)``

### Alignment

- ``Alignment``

### Placement

- ``Placement``

### Interpolation

- ``ViewInterpolation``

### Tile

- ``tiled(count:padding:resolution:render:)``
- ``tiledConcurrently(count:padding:resolution:render:)``
- ``Tile``
- ``TileError``

### Extend Mode

- ``ExtendMode``

### Copy

- ``copy()``

### Empty

- ``empty()``

### Options

- ``ContentOptions``
- ``EffectOptions``

### Debug

- ``quickLookDebugActive``

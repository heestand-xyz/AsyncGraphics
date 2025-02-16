# ``AsyncGraphics/Graphic3D``

A Graphic3D is a 3d image, made up out of voxels. It's backed by a `MTLTexture`. 

## Topics

### Data

- ``texture``

### Metadata

- ``id``
- ``bits``
- ``colorSpace``

### Resolution

- ``width``
- ``height``
- ``depth``
- ``resolution``

### Bits

- ``withBits(_:options:)``
- ``bits(_:)``

### Options

- ``ContentOptions``
- ``EffectOptions``

### Voxels

- ``voxelCount``
- ``voxel(x:y:z:options:)``
- ``voxel(u:v:w:options:)``
- ``firstVoxelColor``
- ``averageVoxelColor``
- ``voxelColors``
- ``isVoxelsEqual(to:)``
- ``voxels(_:options:)``

### Channels

- ``channels``
- ``channels(_:resolution:)-79xqi``
- ``channels(_:resolution:)-5dz0k``
- ``channels(_:resolution:)-5dz0k``
- ``channels(pointer:resolution:)-8w75m``
- ``channels(pointer:resolution:)-r9wl``
- ``channels(pointer:resolution:)-r9wl``

### Texture

- ``texture(_:)``
- ``Texture3DError``

## Content

### Color

- ``color(_:resolution:options:)``

### Box

- ``box(size:origin:cornerRadius:color:backgroundColor:resolution:tile:options:)``
- ``box(size:position:cornerRadius:color:backgroundColor:resolution:tile:options:)``
- ``surfaceBox(size:origin:cornerRadius:surfaceWidth:color:backgroundColor:resolution:tile:options:)``
- ``surfaceBox(size:position:cornerRadius:surfaceWidth:color:backgroundColor:resolution:tile:options:)``

### Sphere

- ``sphere(radius:position:color:backgroundColor:resolution:tile:options:)``
- ``surfaceSphere(radius:position:surfaceWidth:color:backgroundColor:resolution:tile:options:)``

### Cone

- ``cone(axis:length:leadingRadius:trailingRadius:position:color:backgroundColor:resolution:tile:options:)``
- ``surfaceCone(axis:length:leadingRadius:trailingRadius:position:surfaceWidth:color:backgroundColor:resolution:tile:options:)``

### Cylinder

- ``cylinder(axis:length:radius:cornerRadius:position:color:backgroundColor:resolution:tile:options:)``
- ``surfaceCylinder(axis:length:radius:cornerRadius:position:surfaceWidth:color:backgroundColor:resolution:tile:options:)``

### Tetrahedron

- ``tetrahedron(axis:radius:position:color:backgroundColor:resolution:tile:options:)``
- ``surfaceTetrahedron(axis:radius:position:surfaceWidth:color:backgroundColor:resolution:tile:options:)``

### Torus

- ``torus(axis:radius:revolvingRadius:position:color:backgroundColor:resolution:tile:options:)``
- ``surfaceTorus(axis:radius:revolvingRadius:position:surfaceWidth:color:backgroundColor:resolution:tile:options:)``

### Gradient

- ``gradient(direction:stops:position:scale:offset:extend:gamma:resolution:tile:options:)``
- ``Gradient3DDirection``

### Noise
- ``noise(offset:depth:scale:octaves:seed:resolution:tile:options:)``
- ``coloredNoise(offset:depth:scale:octaves:seed:resolution:tile:options:)``
- ``randomNoise(seed:resolution:tile:options:)``
- ``randomColoredNoise(seed:resolution:tile:options:)``
- ``transparantNoise(offset:depth:scale:octaves:seed:resolution:tile:options:)``

### Metal

- ``metal(code:resolution:options:)``
- ``SolidMetal3DError``

### Map

- ``uvw(resolution:options:)``

## Effects

### Blend

Use blending modes to combine two 3d graphics.

- ``blend(with:blendingMode:placement:options:)``
- ``blended(with:blendingMode:placement:options:)``

### Transform

- ``translated(_:options:)``
- ``translated(x:y:z:options:)``
- ``rotated(_:options:)``
- ``rotated(x:y:z:options:)``
- ``scaled(_:options:)-7kcho``
- ``scaled(_:options:)-8aoeu``
- ``scaled(x:y:z:options:)``
- ``transformed(translation:rotation:scale:scaleSize:options:)``

### Luma Transform

- ``lumaOffset(with:translation:lumaGamma:placement:options:)``
- ``lumaOffset(with:x:y:z:lumaGamma:placement:options:)``
- ``lumaRotated(with:rotation:lumaGamma:placement:options:)``
- ``lumaScaled(with:scale:lumaGamma:placement:options:)``
- ``lumaScaled(with:x:y:z:lumaGamma:placement:options:)``

### Stack

- ``hStacked(with:yAlignment:zAlignment:spacing:padding:backgroundColor:options:)``
- ``vStacked(with:xAlignment:zAlignment:spacing:padding:backgroundColor:options:)``
- ``dStacked(with:xAlignment:yAlignment:spacing:padding:backgroundColor:options:)``
- ``Alignment3D``

### Levels

- ``brightness(_:options:)``
- ``darkness(_:options:)``
- ``contrast(_:options:)``
- ``gamma(_:options:)``
- ``inverted(options:)``
- ``smoothed(options:)``
- ``opacity(_:options:)``
- ``exposureOffset(_:options:)``
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

- ``saturated(_:options:)``
- ``monochrome(options:)``
- ``hue(_:options:)``
- ``tinted(_:options:)``

### Luma Color Shift

- ``lumaMonochrome(with:lumaGamma:placement:options:)``
- ``lumaSaturated(with:saturation:lumaGamma:placement:options:)``
- ``lumaHue(with:hue:lumaGamma:placement:options:)``
- ``lumaTinted(with:color:lumaGamma:placement:options:)``

### Blur

- ``blurredBox(radius:sampleCount:options:)``
- ``blurredZoom(radius:position:sampleCount:options:)``
- ``blurredDirection(radius:direction:sampleCount:options:)``
- ``blurredRandom(radius:options:)``
- ``Blur3DType``

### Luma Blur

- ``lumaBlurredBox(with:radius:lumaGamma:sampleCount:placement:options:)``
- ``lumaBlurredZoom(with:radius:position:lumaGamma:sampleCount:placement:options:)``
- ``lumaBlurredRandom(with:radius:lumaGamma:placement:options:)``
- ``LumaBlur3DType``

### Luma Rainbow Blur

- ``lumaRainbowBlurredCircle(with:radius:angle:light:lumaGamma:sampleCount:placement:options:)``
- ``lumaRainbowBlurredZoom(with:radius:position:light:lumaGamma:sampleCount:placement:options:)``
- ``lumaBlurredRandom(with:radius:lumaGamma:placement:options:)``
- ``LumaRainbowBlur3DType``

### Displace

- ``displaced(with:offset:origin:placement:options:)``

### Edge

- ``edge(amplitude:distance:isTransparent:options:)``
- ``coloredEdge(amplitude:distance:isTransparent:options:)``

### Slope

- ``slope(amplitude:origin:options:)``

### Threshold

- ``threshold(_:color:backgroundColor:options:)``

### Cross

Fade two graphics by crossing them with opacity.

- ``cross(with:fraction:placement:options:)``

### Channel Mix

- ``channelMix(red:green:blue:alpha:options:)``

### Clamp

- ``clamp(_:low:high:includeAlpha:options:)``

### Crop

- ``crop(to:options:)``

### Color Map

- ``colorMap(from:to:options:)``

### Lookup

- ``lookup(with:axis:sampleCoordinate:options:)``
- ``Lookup3DAxis``

### Gradient Lookup

- ``gradientLookup(stops:gamma:options:)``

### Quantize

- ``quantize(_:options:)``

### Range

- ``range(referenceLow:referenceHigh:targetLow:targetHigh:includeAlpha:options:)``

### Sample

Sample a ``Graphic`` from a Graphic3D.

- ``add(axis:brightness:options:)``
- ``average(axis:options:)``
- ``sample(fraction:)``
- ``sample(index:)``
- ``samples(progress:)``
- ``SampleProgress``

### Trace

Trace opaque voxels. 

- ``trace(axis:reversed:alphaThreshold:)``

### Orbit

- ``orbit(backgroundColor:rotationX:rotationY:resolution:)``

### Polar

- ``polar(radius:resolution:options:)``

### Conversion

- ``luminanceToAlpha()``
- ``luminanceToAlphaWithColor()``
- ``alphaToLuminance()``
- ``alphaToLuminanceWithAlpha()``

### Tiles

- ``tiled(count:padding:resolution:render:)``
- ``tiledConcurrently(count:padding:resolution:render:)``
- ``Tile``
- ``TileError``

### Axis

- ``Axis``

### Construct

- ``construct(graphics:options:)``

### Empty

- ``empty()``

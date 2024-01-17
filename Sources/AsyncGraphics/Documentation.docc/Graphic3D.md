# ``AsyncGraphics/Graphic3D``

A Graphic3D is a 3d image, made up out of voxels. It's backed by a `MTLTexture`. 

## Topics

### Data

- ``texture``

### Metadata

- ``bits``
- ``colorSpace``

### Resolution

- ``width``
- ``height``
- ``depth``
- ``resolution``

### Bits

- ``bits(_:)``

### Options

- ``ContentOptions``
- ``EffectOptions``

### Voxels

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

- ``box(size:origin:cornerRadius:color:backgroundColor:resolution:options:)``
- ``box(size:position:cornerRadius:color:backgroundColor:resolution:options:)``
- ``surfaceBox(size:origin:cornerRadius:surfaceWidth:color:backgroundColor:resolution:options:)``
- ``surfaceBox(size:position:cornerRadius:surfaceWidth:color:backgroundColor:resolution:options:)``

### Sphere

- ``sphere(radius:position:color:backgroundColor:resolution:options:)``
- ``surfaceSphere(radius:position:surfaceWidth:color:backgroundColor:resolution:options:)``

### Cone

- ``cone(axis:length:leadingRadius:trailingRadius:position:color:backgroundColor:resolution:options:)``
- ``surfaceCone(axis:length:leadingRadius:trailingRadius:position:surfaceWidth:color:backgroundColor:resolution:options:)``

### Cylinder

- ``cylinder(axis:length:radius:cornerRadius:position:color:backgroundColor:resolution:options:)``
- ``surfaceCylinder(axis:length:radius:cornerRadius:position:surfaceWidth:color:backgroundColor:resolution:options:)``

### Tetrahedron

- ``tetrahedron(axis:radius:position:color:backgroundColor:resolution:options:)``
- ``surfaceTetrahedron(axis:radius:position:surfaceWidth:color:backgroundColor:resolution:options:)``

### Torus

- ``torus(axis:radius:revolvingRadius:position:color:backgroundColor:resolution:options:)``
- ``surfaceTorus(axis:radius:revolvingRadius:position:surfaceWidth:color:backgroundColor:resolution:options:)``

### Gradient

- ``gradient(direction:stops:position:scale:offset:extend:gamma:resolution:options:)``

### Noise
- ``noise(offset:depth:scale:octaves:seed:resolution:options:)``
- ``coloredNoise(offset:depth:scale:octaves:seed:resolution:options:)``
- ``randomNoise(seed:resolution:options:)``
- ``randomColoredNoise(seed:resolution:options:)``
- ``transparantNoise(offset:depth:scale:octaves:seed:resolution:options:)``

### Metal

- ``metal(code:resolution:options:)``

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

### Stack

- ``hStack(with:alignment:spacing:padding:backgroundColor:resolution:)``
- ``vStack(with:alignment:spacing:padding:backgroundColor:resolution:)``
- ``dStack(with:alignment:spacing:padding:backgroundColor:resolution:)``
- ``HStackAlignment``
- ``VStackAlignment``
- ``DStackAlignment``

### Levels

- ``brightness(_:)``
- ``darkness(_:)``
- ``contrast(_:)``
- ``gamma(_:)``
- ``inverted()``
- ``smoothed()``
- ``opacity(_:)``
- ``exposureOffset(_:)``
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

- ``saturated(_:)``
- ``monochrome()``
- ``hue(_:)``
- ``tinted(_:)``

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

### Luma Blur

- ``lumaBlurredBox(with:radius:lumaGamma:sampleCount:placement:options:)``
- ``lumaBlurredZoom(with:radius:position:lumaGamma:sampleCount:placement:options:)``
- ``lumaBlurredRandom(with:radius:lumaGamma:placement:options:)``

### Luma Rainbow Blur

- ``lumaRainbowBlurredCircle(with:radius:angle:light:lumaGamma:sampleCount:placement:options:)``
- ``lumaRainbowBlurredAngle(with:radius:angle:light:lumaGamma:sampleCount:placement:options:)``
- ``lumaRainbowBlurredZoom(with:radius:position:light:lumaGamma:sampleCount:placement:options:)``

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

- ``channelMix(red:green:blue:alpha:)``

### Clamp

- ``clamp(_:low:high:includeAlpha:options:)``

### Color Map

- ``colorMap(from:to:options:)``

### Lookup

- ``lookup(with:axis:sampleCoordinate:options:)``

### Gradient Lookup

- ``gradientLookup(stops:gamma:options:)``

### Quantize

- ``quantize(_:options:)``

### Sample

Sample a ``Graphic`` from a Graphic3D.

- ``add(axis:brightness:)``
- ``average(axis:)``
- ``sample(fraction:)``
- ``sample(index:)``
- ``samples(progress:)``

### Trace

Trace opaque voxels. 

- ``trace(axis:alphaThreshold:)``

### Orbit

- ``orbit(backgroundColor:rotationX:rotationY:resolution:)``

### Conversion

- ``luminanceToAlpha()``
- ``alphaToLuminance()``
- ``alphaToLuminanceWithAlpha()``

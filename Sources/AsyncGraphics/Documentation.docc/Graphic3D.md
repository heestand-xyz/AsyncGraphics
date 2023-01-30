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

### Options

- ``ContentOptions``
- ``EffectOptions``

### Voxels

- ``firstVoxelColor``
- ``averageVoxelColor``
- ``voxelColors``
- ``channels``
- ``isVoxelsEqual(to:)``

### Texture

- ``texture(_:)``
- ``Texture3DError``

### Color

- ``color(_:resolution:options:)``

### Box

- ``box(size:origin:cornerRadius:color:backgroundColor:resolution:options:)``
- ``box(size:center:cornerRadius:color:backgroundColor:resolution:options:)``
- ``surfaceBox(size:origin:cornerRadius:surfaceWidth:color:backgroundColor:resolution:options:)``
- ``surfaceBox(size:center:cornerRadius:surfaceWidth:color:backgroundColor:resolution:options:)``

### Sphere

- ``sphere(radius:center:color:backgroundColor:resolution:options:)``
- ``surfaceSphere(radius:center:surfaceWidth:color:backgroundColor:resolution:options:)``

### Noise
- ``noise(offset:depth:scale:octaves:seed:resolution:options:)``
- ``coloredNoise(offset:depth:scale:octaves:seed:resolution:options:)``
- ``randomNoise(seed:resolution:options:)``
- ``randomColoredNoise(seed:resolution:options:)``

### Blend

Use blending modes to combine two 3d graphics.

- ``blended(with:blendingMode:placement:)``

### Transform

- ``translated(_:options:)``
- ``translated(x:y:z:options:)``
- ``rotated(_:options:)``
- ``rotated(x:y:z:options:)``
- ``scaled(_:options:)-87l2t``
- ``scaled(_:options:)-7kcho``
- ``scaled(x:y:z:options:)``

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

### Blur

- ``blurredBox(radius:sampleCount:options:)``
- ``blurredZoom(radius:center:sampleCount:options:)``
- ``blurredDirection(radius:direction:sampleCount:options:)``
- ``blurredRandom(radius:options:)``

### Displace

- ``displaced(with:offset:origin:placement:options:)``

### Edge

- ``edge(amplitude:distance:options:)``
- ``coloredEdge(amplitude:distance:options:)``

### Cross

Fade two graphics by crossing them with opacity.

- ``cross(with:fraction:placement:)``

### Sample

Sample a ``Graphic`` from a Graphic3D.

- ``add(axis:)``
- ``average(axis:)``
- ``sample(fraction:)``
- ``sample(index:)``
- ``samples()``

### Bits

- ``bits(_:)``
- ``standardBit()``
- ``highBit()``

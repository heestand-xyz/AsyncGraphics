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

### Voxels

- ``firstVoxelColor``
- ``averageVoxelColor``
- ``voxelColors``
- ``channels``
<!--- ``isVoxelsEqual(to:)``-->

### Resources

- ``texture(_:)``

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

### Blend

- ``blended(with:blendingMode:placement:)``

### Technical

- ``average(axis:)``
- ``sample(fraction:axis:)``
- ``sample(index:axis:)``
- ``samples(axis:)``

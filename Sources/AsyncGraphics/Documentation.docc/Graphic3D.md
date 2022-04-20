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

- ``texture(_:colorSpace:)``

### Color

- ``color(_:at:)``

### Box

- ``box(size:origin:cornerRadius:color:backgroundColor:at:)``
- ``box(size:center:cornerRadius:color:backgroundColor:at:)``
- ``surfaceBox(size:origin:cornerRadius:surfaceWidth:color:backgroundColor:at:)``
- ``surfaceBox(size:center:cornerRadius:surfaceWidth:color:backgroundColor:at:)``

### Sphere

- ``sphere(radius:center:color:backgroundColor:at:)``
- ``surfaceSphere(radius:center:surfaceWidth:color:backgroundColor:at:)``

### Blend

- ``blended(with:blendingMode:placement:)``

### Technical

- ``average(axis:)``
- ``sample(fraction:axis:)``
- ``sample(index:axis:)``
- ``samples(axis:)``

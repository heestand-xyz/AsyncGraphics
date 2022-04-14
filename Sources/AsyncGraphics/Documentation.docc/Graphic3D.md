# ``AsyncGraphics/Graphic3D``

A Graphic3D is a volume of voxels. It's backed by a `MTLTexture`. 

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

### Content Resources

- ``texture(_:colorSpace:)``

### Content Shapes

- ``color(_:at:)``
- ``box(size:origin:cornerRadius:color:backgroundColor:at:)``
- ``box(size:center:cornerRadius:color:backgroundColor:at:)``
- ``surfaceBox(size:origin:cornerRadius:surfaceWidth:color:backgroundColor:at:)``
- ``surfaceBox(size:center:cornerRadius:surfaceWidth:color:backgroundColor:at:)``
- ``sphere(radius:center:color:backgroundColor:at:)``
- ``surfaceSphere(radius:center:surfaceWidth:color:backgroundColor:at:)``

### Effects Direct

- ``blurred(radius:)``
- ``inverted()``

### Effects Dual

- ``blended(with:blendingMode:placement:)``
- ``displaced(with:offset:origin:placement:)``

### Effects Technical

- ``bits(_:)``
- ``average(axis:)``
- ``sample(fraction:axis:)``
- ``sample(index:axis:)``
- ``samples(axis:)``

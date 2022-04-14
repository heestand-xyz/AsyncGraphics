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

- ``width``
- ``height``
- ``size``
- ``resolution``

### Pixels

- ``firstPixelColor``
- ``averagePixelColor``
- ``pixelColors``
- ``channels``
- ``isPixelsEqual(to:)``

### Content Resources

- ``image(_:)``
- ``image(named:in:)``
- ``texture(_:colorSpace:)``

### Content Shapes

- ``color(_:at:)``
- ``rectangle(size:center:cornerRadius:color:backgroundColor:at:)``
- ``rectangle(frame:cornerRadius:color:backgroundColor:at:)``
- ``strokedRectangle(size:center:cornerRadius:lineWidth:color:backgroundColor:at:)``
- ``strokedRectangle(frame:cornerRadius:lineWidth:color:backgroundColor:at:)``
- ``circle(radius:center:color:backgroundColor:at:)``
- ``strokedCircle(radius:center:lineWidth:color:backgroundColor:at:)``

### Effects Direct

- ``blurred(radius:)``
- ``inverted()``

### Effects Dual

- ``blended(with:blendingMode:placement:)``
- ``displaced(with:offset:origin:placement:)``

### Effects Technical

- ``bits(_:)``
- ``reduce(by:)``
- ``reduce(by:in:)``
- ``ReduceMethod``
- ``ReduceAxis``

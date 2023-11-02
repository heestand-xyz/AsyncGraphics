# LUTs

Lookup tables.

## Overview

A LUT is a way to store color adjustments in a file.

In AsyncGraphics you can import and export LUTs in the `.cube` format.

## Example

Identity LUT:

![LUT](http://async.graphics/Images/LUTs/LUT.png)
![Image](http://async.graphics/Images/LUTs/Image.png)

120° Hue LUT:

![LUT Hue 120](http://async.graphics/Images/LUTs/LUT_Hue_120.png)
![Image Hue 120](http://async.graphics/Images/LUTs/Image_Hue_120.png)

50% Saturation LUT:

![LUT Sat 50](http://async.graphics/Images/LUTs/LUT_Sat_50.png)
![Image Sat 50](http://async.graphics/Images/LUTs/Image_Sat_50.png)

## Topics

### Import

- ``Graphic/readLUT(url:layout:)``
- ``Graphic/readLUT(data:format:layout:)``
- ``Graphic/readLUT(named:format:layout:)``
- ``Graphic/readLUT(named:in:format:layout:)``

### Export

- ``Graphic/writeLUT(layout:)``

### Apply

- ``Graphic/applyLUT(with:layout:)``
- ``Graphic/applyLUT(url:)``
- ``Graphic/applyLUT(named:format:)``
- ``Graphic/applyLUT(named:in:format:)``

### Identity

Used for creating a new LUT.

- ``Graphic/identityLUT(size:layout:options:)``

### Size

- ``Graphic/sizeOfLUT()``
- ``Graphic/sizeOfLUT(url:)``
- ``Graphic/sizeOfLUT(data:format:)``
- ``Graphic/sizeOfLUT(named:format:)``
- ``Graphic/sizeOfLUT(named:in:format:)``

### Layout

- ``Graphic/layoutOfLUT()``
- ``Graphic/idealLayoutOfLUT(size:)``
- ``Graphic/idealLayoutOfLUT(url:)``
- ``Graphic/idealLayoutOfLUT(data:format:)``
- ``Graphic/idealLayoutOfLUT(named:format:)``
- ``Graphic/idealLayoutOfLUT(named:in:format:)``

### Sample

- ``Graphic/sampleOfLUT(at:layout:)``

### Structs

- ``Graphic/LUTLayout``
- ``Graphic/LUTFormat``
- ``Graphic/LUTError``

# LUTs

Lookup tables.

## Overview

A LUT is a way to store color adjustments in a file.

In AsyncGraphics you can import and export LUTs in the `.cube` format.

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

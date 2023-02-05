# Resources

Import and export footage. 

## Overview

Images, videos and various pixel formats can be converted to a ``Graphic``.

Live screen or camera footage can also be converted into a stream of ``Graphic``.

## Topics

### Live Camera Feed

- ``Graphic/camera(_:device:preset:)``

### Live Screen Feed

- ``Graphic/screen(at:)``

### Import an Image

- ``Graphic/image(named:in:)``
- ``Graphic/image(url:)``
- ``Graphic/image(_:)``

### Import a Video

- ``Graphic/importVideoFrame(at:url:info:)``
- ``Graphic/importVideo(url:progress:)``
- ``Graphic/importVideoStream(url:)``

### Import a Buffer

- ``Graphic/pixelBuffer(_:)``
- ``Graphic/sampleBuffer(_:)``

### Import a Texture

- ``Graphic/texture(_:)``

### Export an Image

- ``Graphic/image``
- ``Graphic/imageWithTransparency``
- ``Graphic/pngData``

### Export a Video

- ``Graphic/exportVideoToData(with:fps:kbps:format:)``
- ``Graphic/exportVideoToURL(with:fps:kbps:format:)``

### Apple Maps

- ``Graphic/maps(type:latitude:longitude:span:resolution:mapOptions:options:)``
- ``Graphic/MapType``
- ``Graphic/MapOptions``

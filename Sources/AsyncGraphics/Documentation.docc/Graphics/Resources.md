# Resources

Import and export footage. 

## Overview

Images, videos and various pixel formats can be converted to a ``Graphic``.

Live screen or camera footage can also be converted into a stream of ``Graphic``.

## Topics

### Live Camera Feed

- ``Graphic/camera(at:lens:quality:)``
- ``Graphic/camera(device:quality:)``
- ``Graphic/camera(with:)``

### Live Screen Feed

- ``Graphic/screen(at:)``

### Import an Image

- ``Graphic/image(named:options:)``
- ``Graphic/image(url:options:)``
- ``Graphic/image(data:options:)``

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

- ``Graphic/exportVideoToData(with:fps:kbps:format:codec:)``
- ``Graphic/exportVideoToURL(with:fps:kbps:format:codec:)``

### Apple Maps

- ``Graphic/maps(type:latitude:longitude:span:resolution:mapOptions:options:)``
- ``Graphic/MapType``
- ``Graphic/MapOptions``

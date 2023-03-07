# ``AsyncGraphics``

Edit images and video with async / await in Swift, powered by Metal.

## Overview

The main value type in **AsyncGraphics** is a ``Graphic``. It's like an image, but with various various methods for applying effects and some static methods for creating visuals.

**AsyncGraphics** also has another value type called ``Graphic3D``. It's a 3d image, a volume of voxels.

[AsyncGraphics on GitHub](https://github.com/heestand-xyz/AsyncGraphics)

## Topics

### Articles

- <doc:Blending>
- <doc:Layout>
- <doc:LiveCamera>
- <doc:VideoEditing>
- <doc:VideoPlayback>

### Graphics

- ``AGGraph``
- ``Graphic``
- ``Graphic3D``

### Views

- ``AGView``
- ``GraphicView``
- ``Graphic3DView``

### Video

- ``GraphicVideoPlayer``
- ``GraphicVideoRecorder``

### Lists

- <doc:Resources>
- <doc:Visuals>
- <doc:Effects>
- <doc:Metal>

### Layout

- ``AGFrame``
- ``AGZStack``
- ``AGVStack``
- ``AGHStack``
- ``AGSpacer``
- ``AGPadding``
- ``AGAspectRatio``

### Resources

- ``AGImage``
- ``AGVideo``
- ``AGCamera``

### Shapes

- ``AGCircle``
- ``AGRectangle``
- ``AGRoundedRectangle``
- ``AGPolygon``
- ``AGRoundedPolygon``

### Color

- ``AGColor``
- ``AGForegroundColor``
- ``AGBorder``

### Effects

- ``AGBlur``
- ``AGChannelMix``
- ``AGNoise``

### Blending

- ``AGBlend``
- ``AGMask``
- ``AGBackground``
- ``AGOpacity``

### Loop

- ``AGForEach``

### Other

- ``AGGraphBuilder``
- ``AGSpecification``
- ``AGDetails``

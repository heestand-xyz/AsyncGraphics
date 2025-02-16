# ``AsyncGraphics``

Edit images and video with async / await in Swift, powered by Metal.

## Overview

The main value type in **AsyncGraphics** is a ``Graphic``. It's like an image, but with various various methods for applying effects and some static methods for creating visuals.

**AsyncGraphics** also has another value type called ``Graphic3D``. It's a 3d image, a volume of voxels.

[AsyncGraphics on GitHub](https://github.com/heestand-xyz/AsyncGraphics)

## Topics

### Graphics

- ``Graphic``
- ``Graphic3D``

### Codable Graphics

- ``CodableGraphic``
- ``CodableGraphic3D``

### Articles

- <doc:Blending>
- <doc:Layout>
- <doc:Camera>
- <doc:VideoEditing>
- <doc:VideoPlayback>

### References

- <doc:Resources>
- <doc:Metal>
- <doc:LUTs>

### Views

- ``AGView``
- ``GraphicView``
- ``Graphic3DView``
- ``AsyncGraphicView``
- ``GraphicRenderView``

### Renderers

- ``GraphicViewRenderer``
- ``GraphicImageRenderer``

### Render Views

- ``GraphicImageRenderView``

### Graphs

- ``AGGraph``
- ``AGGraphic``

### Video

- ``GraphicVideoPlayer``
- ``GraphicVideoRecorder``
- ``GraphicRecorder``

### Layout

- ``AGFrame``
- ``AGZStack``
- ``AGVStack``
- ``AGHStack``
- ``AGSpacer``
- ``AGPadding``
- ``AGAspectRatio``
- ``AGOffset``

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
- ``AGBackgroundColor``
- ``AGBorder``

### Effects

- ``AGBlur``
- ``AGChannelMix``
- ``AGNoise``

### Blending

- ``AGBlend``
- ``AGBlended``
- ``AGMask``
- ``AGBackground``
- ``AGOpacity``

### Loop

- ``AGForEach``

### Other AGs

- ``AGGraphBuilder``
- ``AGSpecification``
- ``AGComponents``
- ``AGDetails``
- ``AGGroup``
- ``AGContentMode``

### Render State

- ``GraphicRenderState``
- ``Graphic3DRenderState``

## Codable

### Codable Properties

- ``GraphicPropertyType``

- ``GraphicValueProperty``
- ``GraphicEnumProperty``

- ``AnyGraphicProperty``
- ``AnyGraphicValueProperty``
- ``AnyGraphicEnumProperty``

### Codable Values

- ``GraphicValueType``

- ``GraphicValue``

- ``GraphicEnum``
- ``GraphicEnumCase``

- ``GraphicMetadataValue``
- ``GraphicMetadata``
- ``GraphicEnumMetadata``
- ``GraphicMetadataOptions``

- ``GraphicVariant``
- ``CodableGraphicVariant``
- ``CodableGraphic3DVariant``
- ``GraphicVariantID``

### Codable Protocols

- ``CodableGraphicProtocol``
- ``CodableGraphic3DProtocol``

- ``ContentGraphicProtocol``
- ``ContentGraphic3DProtocol``

- ``ShapeContentGraphicProtocol``
- ``ShapeContentGraphic3DProtocol``

- ``SolidContentGraphicProtocol``
- ``SolidContentGraphic3DProtocol``

- ``EffectGraphicProtocol``
- ``EffectGraphic3DProtocol``

- ``ColorEffectGraphicProtocol``
- ``ColorEffectGraphic3DProtocol``

- ``SpaceEffectGraphicProtocol``
- ``SpaceEffectGraphic3DProtocol``

- ``ModifierEffectGraphicProtocol``
- ``ModifierEffectGraphic3DProtocol``

- ``ConvertEffectGraphicProtocol``
- ``ConvertEffectGraphic3DProtocol``

### Codable Types

- ``CodableGraphicType``
- ``CodableGraphic3DType``

- ``ContentGraphicType``
- ``ContentGraphic3DType``

- ``ShapeContentGraphicType``
- ``ShapeContentGraphic3DType``

- ``SolidContentGraphicType``
- ``SolidContentGraphic3DType``

- ``EffectGraphicType``
- ``EffectGraphic3DType``

- ``ColorEffectGraphicType``
- ``ColorEffectGraphic3DType``

- ``SpaceEffectGraphicType``
- ``SpaceEffectGraphic3DType``

- ``ModifierEffectGraphicType``
- ``ModifierEffectGraphic3DType``

- ``ConvertEffectGraphicType``
- ``ConvertEffectGraphic3DType``

### Images

- ``SendableImage``

### Renderer

- ``Renderer``
- ``AGGraphRenderer``

### Render Actor

- ``RenderActor``

### Complexity

- ``GraphicComplexity``

# Visuals

Create visuals. 

## Overview

Create various shapes and visuals.

## Topics

### Color

Create a graphic with a solid color.

- ``Graphic/color(_:resolution:options:)``

### Text

- ``Graphic/text(_:font:center:horizontalAlignment:verticalAlignment:color:backgroundColor:resolution:options:)``
- ``Graphic/TextFont``
- ``Graphic/TextHorizontalAlignment``
- ``Graphic/TextVerticalAlignment``

### Rectangle

- ``Graphic/rectangle(size:center:cornerRadius:color:backgroundColor:resolution:options:)``
- ``Graphic/rectangle(frame:cornerRadius:color:backgroundColor:resolution:options:)``
- ``Graphic/strokedRectangle(size:center:cornerRadius:lineWidth:color:backgroundColor:resolution:options:)``
- ``Graphic/strokedRectangle(frame:cornerRadius:lineWidth:color:backgroundColor:resolution:options:)``

### Circle

- ``Graphic/circle(radius:center:color:backgroundColor:resolution:options:)``
- ``Graphic/strokedCircle(radius:center:lineWidth:color:backgroundColor:resolution:options:)``

### Polygon

- ``Graphic/polygon(count:radius:center:rotation:cornerRadius:color:backgroundColor:resolution:options:)``

### Gradient

- ``Graphic/gradient(direction:stops:center:scale:offset:extend:gamma:resolution:options:)``
- ``Graphic/GradientDirection``
- ``Graphic/GradientStop``
- ``Graphic/GradientExtend``

### Noise

- ``Graphic/noise(offset:depth:scale:octaves:seed:resolution:options:)``
- ``Graphic/coloredNoise(offset:depth:scale:octaves:seed:resolution:options:)``
- ``Graphic/randomNoise(seed:resolution:options:)``
- ``Graphic/randomColoredNoise(seed:resolution:options:)``

### Particles

- ``Graphic/uvParticles(particleScale:particleColor:backgroundColor:resolution:sampleCount:particleOptions:options:)``
- ``Graphic/uvColorParticles(with:particleScale:backgroundColor:resolution:sampleCount:particleOptions:options:)``
- ``Graphic/UVParticleSampleCount``
- ``Graphic/UVParticleOptions``
- ``Graphic/UVColorParticleOptions``

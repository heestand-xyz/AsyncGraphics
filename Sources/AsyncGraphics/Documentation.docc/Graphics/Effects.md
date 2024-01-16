# Effects

Create effects. 

## Overview

Create effects to modify color brightness and displacement.

## Topics

### Blend

Use blending modes to combine two or more graphics.

- ``Graphic/blended(with:blendingMode:placement:alignment:options:)``
- ``Graphic/blend(with:blendingMode:)``
- ``Graphic/add(with:)``
- ``Graphic/average(with:)``
- ``Graphic/mask(foreground:background:mask:placement:options:)``

### Transform

- ``Graphic/offset(_:options:)``
- ``Graphic/rotated(_:options:)``
- ``Graphic/scaled(_:options:)``
- ``Graphic/sized(width:height:options:)``
- ``Graphic/sized(_:options:)``
- ``Graphic/transformed(translation:rotation:scale:size:options:)``

### Luma Transform

- ``Graphic/lumaOffset(with:translation:lumaGamma:placement:options:)``
- ``Graphic/lumaOffset(with:x:y:lumaGamma:placement:options:)``
- ``Graphic/lumaRotated(with:rotation:lumaGamma:placement:options:)``
- ``Graphic/lumaScaled(with:scale:lumaGamma:placement:options:)``
- ``Graphic/lumaScaled(with:x:y:lumaGamma:placement:options:)``

### Transform with Blend

- ``Graphic/transformBlended(with:blendingMode:placement:alignment:translation:rotation:scale:size:options:)``

### Mirror

- ``Graphic/mirroredHorizontally()``
- ``Graphic/mirroredVertically()``

### Rotate

- ``Graphic/rotatedLeft()``
- ``Graphic/rotatedRight()``

### Stack

- ``Graphic/hStack(with:alignment:spacing:padding:backgroundColor:resolution:)``
- ``Graphic/vStack(with:alignment:spacing:padding:backgroundColor:resolution:)``
- ``Graphic/HStackAlignment``
- ``Graphic/VStackAlignment``

### Levels

- ``Graphic/brightness(_:)``
- ``Graphic/darkness(_:)``
- ``Graphic/contrast(_:)``
- ``Graphic/gamma(_:)``
- ``Graphic/inverted()``
- ``Graphic/smoothed()``
- ``Graphic/opacity(_:)``
- ``Graphic/exposureOffset(_:)``
- ``Graphic/add(_:)``
- ``Graphic/subtract(_:)``
- ``Graphic/multiply(_:)``
- ``Graphic/divide(_:)``
- ``Graphic/levels(brightness:darkness:contrast:gamma:invert:smooth:opacity:offset:)``

### Luma Levels

- ``Graphic/lumaBrightness(with:brightness:lumaGamma:placement:)``
- ``Graphic/lumaDarkness(with:darkness:lumaGamma:placement:)``
- ``Graphic/lumaContrast(with:contrast:lumaGamma:placement:)``
- ``Graphic/lumaGamma(with:gamma:lumaGamma:placement:)``
- ``Graphic/lumaInverted(with:lumaGamma:placement:)``
- ``Graphic/lumaSmoothed(with:lumaGamma:placement:)``
- ``Graphic/lumaOpacity(with:opacity:lumaGamma:placement:)``
- ``Graphic/lumaExposureOffset(with:offset:lumaGamma:placement:)``
- ``Graphic/lumaAdd(with:value:lumaGamma:placement:)``
- ``Graphic/lumaSubtract(with:value:lumaGamma:placement:)``
- ``Graphic/lumaMultiply(with:value:lumaGamma:placement:)``
- ``Graphic/lumaDivide(with:value:lumaGamma:placement:)``

### Colors

- ``Graphic/monochrome()``
- ``Graphic/saturated(_:)``
- ``Graphic/hue(_:)``
- ``Graphic/tinted(_:)``

### Luma Colors

- ``Graphic/lumaMonochrome(with:lumaGamma:)``
- ``Graphic/lumaMonochrome(with:lumaGamma:)``
- ``Graphic/lumaSaturated(with:saturation:lumaGamma:)``
- ``Graphic/lumaHue(with:hue:lumaGamma:)``
- ``Graphic/lumaTinted(with:color:lumaGamma:)``

### Color Convert

- ``Graphic/colorConvert(_:channel:)``
- ``Graphic/ColorConversion``
- ``Graphic/ColorConvertChannel``

### Threshold

- ``Graphic/threshold(_:color:backgroundColor:options:)``

### Quantize

- ``Graphic/quantize(_:options:)``

### Channels

- ``Graphic/channelMix(red:green:blue:alpha:)``
- ``Graphic/alphaToLuminance()``
- ``Graphic/luminanceToAlpha()``
- ``Graphic/ColorChannel``

### Blur

- ``Graphic/blurred(radius:)``
- ``Graphic/blurredBox(radius:sampleCount:options:)``
- ``Graphic/blurredZoom(radius:position:sampleCount:options:)``
- ``Graphic/blurredAngle(radius:angle:sampleCount:options:)``
- ``Graphic/blurredRandom(radius:options:)``

### Luma Blur

- ``Graphic/lumaBlurredBox(with:radius:lumaGamma:sampleCount:placement:options:)``
- ``Graphic/lumaBlurredZoom(with:radius:position:lumaGamma:sampleCount:placement:options:)``
- ``Graphic/lumaBlurredAngle(with:radius:angle:lumaGamma:sampleCount:placement:options:)``
- ``Graphic/lumaBlurredRandom(with:radius:lumaGamma:placement:options:)``

### Rainbow Blur

- ``Graphic/rainbowBlurredCircle(radius:angle:light:sampleCount:options:)``
- ``Graphic/rainbowBlurredAngle(radius:angle:light:sampleCount:options:)``
- ``Graphic/rainbowBlurredZoom(radius:position:light:sampleCount:options:)``

### Luma Rainbow Blur

- ``Graphic/lumaRainbowBlurredCircle(with:radius:angle:light:lumaGamma:sampleCount:placement:options:)``
- ``Graphic/lumaRainbowBlurredAngle(with:radius:angle:light:lumaGamma:sampleCount:placement:options:)``
- ``Graphic/lumaRainbowBlurredZoom(with:radius:position:light:lumaGamma:sampleCount:placement:options:)``

### Displace

- ``Graphic/displaced(with:offset:origin:placement:options:)``

### Slope

- ``Graphic/slope(amplitude:origin:options:)``

### Edge

- ``Graphic/edge(amplitude:distance:isTransparent:options:)``
- ``Graphic/coloredEdge(amplitude:distance:isTransparent:options:)``

### Clamp

- ``Graphic/clamp(_:low:high:includeAlpha:options:)``
- ``Graphic/ClampType``

### Cross

Fade two graphics by crossing them with opacity.

- ``Graphic/cross(with:fraction:placement:options:)``

### Corner Pin

- ``Graphic/cornerPinned(topLeft:topRight:bottomLeft:bottomRight:perspective:subdivisions:backgroundColor:)``

### Chroma Key

- ``Graphic/chromaKey(color:parameters:options:)``
- ``Graphic/ChromaKeyParameters``

### Polar

- ``Graphic/polar(radius:width:leadingAngle:trailingAngle:resolution:options:)``

### Morph

- ``Graphic/morphedMinimum(size:)``
- ``Graphic/morphedMaximum(size:)``

# ``AsyncGraphics/Graphic/blurred(radius:options:)``

## Overview

Gaussian blur of a ``Graphic``.

![Blur](https://github.com/heestand-xyz/AsyncGraphics-Docs/blob/main/Images/Effects/Blur-Radius-25.png?raw=true)

In this example the blur radius is `25`. 

## Alpha output

All 2D and 3D blur variants accept `.pureAlpha` in their effect options. This
divides the completed blur's RGB by its alpha to produce straight-alpha output
from premultiplied input. Alpha is unchanged, and zero-alpha pixels retain their
RGB without division. Calls without `.pureAlpha` preserve their existing output.

Layered blurs normalize only after the final pass. A layer count below one
returns the input unchanged. When chaining blur operations, keep intermediate
results premultiplied and request `.pureAlpha` only on the last operation.

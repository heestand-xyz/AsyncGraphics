# Blending

Blend graphics with the z stacks and blending modes.

## Overview

![Blending](https://github.com/heestand-xyz/AsyncGraphics-Docs/blob/main/Images/Articles/async-graphics-blending.png?raw=true)

First we create an ``AGView``, this is the container for all ``AGGraph``'s.

In this example we have a ``AGZStack`` with 3 ``AGHStack``s. Each graph has a blend mode (``Graphic/BlendMode``), in this case `.screen`.

```swift
import SwiftUI
import AsyncGraphics

struct ContentView: View {
    var body: some View {
        AGView {
            AGZStack {
                AGHStack {
                    AGSpacer()
                    AGCircle()
                        .foregroundColor(.red)
                }
                AGHStack {
                    AGSpacer()
                    AGCircle()
                        .foregroundColor(.green)
                    AGSpacer()
                }
                .blendMode(.screen)
                AGHStack {
                    AGCircle()
                        .foregroundColor(.blue)
                    AGSpacer()
                }
                .blendMode(.screen)
            }
        }
    }
}
```

## Topics

### Blend Mode

- ``Graphic/BlendMode``

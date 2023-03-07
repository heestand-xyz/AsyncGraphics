# Blending

Blend graphics with the z stacks and blending modes.

## Overview

![Blending](http://async.graphics/Images/Articles/async-graphics-blending.png)

First we create an ``AGView``, this is the container for all ``AGGraph``'s.

In this example we have a ``AGZStack`` with 3 ``AGHStack``s. Each graph has a blend mode (``AGBlendMode``), in this case `.screen`.

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

- ``AGBlendMode``

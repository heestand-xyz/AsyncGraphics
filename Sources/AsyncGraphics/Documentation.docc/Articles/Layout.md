# Layout

Layout graphics with stacks, frames and padding.

## Overview

![Layout](https://github.com/heestand-xyz/AsyncGraphics-Docs/blob/main/Images/Articles/async-graphics-layout.png?raw=true)

First we create an ``AGView``, this is the container for all ``AGGraph``'s.

In this example we create an ``AGHStack`` to contain out boxes, then we loop 3 times with an ``AGForEach``, calculate the width and create ``AGRoundedRectangle``s. After that we set the frame to get a fixed size and apply a color. After the stack we apply some padding and finally add a background.

```swift
import SwiftUI
import AsyncGraphics

struct ContentView: View {
    var body: some View {
        AGView {
            AGHStack(alignment: .top, spacing: 15) {
                AGForEach(0..<3) { index in
                    let width = 50 * CGFloat(index + 1)
                    AGRoundedRectangle(cornerRadius: 15)
                        .frame(width: width, height: width)
                        .foregroundColor(Color(hue: Double(index) / 3,
                                               saturation: 0.5,
                                               brightness: 1.0))
                }
            }
            .padding(15)
            .background {
                AGRoundedRectangle(cornerRadius: 30)
                    .opacity(0.1)
            }
        }
    }
}
```

## Topics

### Stacks

- ``AGZStack``
- ``AGVStack``
- ``AGHStack``

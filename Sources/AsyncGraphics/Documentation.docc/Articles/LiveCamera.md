# Live Camera

Capture live footage from the camera.

## Overview

We start by creating a `State` variable for our ``Graphic``. This will update 60 times a second.

Then we check if the graphic is available and display it with a ``GraphicView``.

Create a task where we can execute async code. Here we also need a do catch block incase the selected camera is not available.

In the task we will create a asynchronous for loop, by iterating over live camera frames from ``Graphic/camera(_:device:preset:)``.

Then lastly we save each frame to the main graphic state. Here you can also add effects such as ``Graphic/blurred(radius:)``.

```swift
import SwiftUI
import AsyncGraphics

struct ContentView: View {

    @State private var graphic: Graphic?

    var body: some View {
        ZStack {
            if let graphic = graphic {
                GraphicView(graphic: graphic)
            } else {
                ProgressView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task {
            do {
                for await cameraGraphic in try Graphic.camera(.front) {
                    graphic = cameraGraphic
                }
            } catch {
                fatalError()
            }
        }
    }
}
```

> If you want to record live ``Graphic``s, use the ``GraphicRecorder``.

## Topics

### Camera

- ``Graphic/camera(_:device:preset:)``

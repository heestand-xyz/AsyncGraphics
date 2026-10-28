# Camera

Capture live footage from the camera.

## Overview

To quickly get started you can add a ``AGCamera``, make it resizable and apply an aspect ratio.

```swift
import SwiftUI
import AsyncGraphics

struct ContentView: View {
    var body: some View {
        AGView {
            AGZStack {
                AGCamera(.front)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }
    }
}
```

To get more control over the capturing we can use ``Graphic``s.

We start by creating a `State` variable for our ``Graphic``. This will update 60 times a second.

Then we check if the graphic is available and display it with a ``GraphicView``.

Create a task where we can execute async code. Here we also need a do catch block incase the selected camera is not available.

In the task we will create a asynchronous for loop, by iterating over live camera frames from ``Graphic/camera(at:lens:quality:)``.

Then lastly we save each frame to the main graphic state. Here you can also add effects such as ``Graphic/blurred(radius:options:)``.

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
                for await cameraGraphic in try await Graphic.camera(at: .front) {
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

## Orientation

On iOS 27 and later, live camera graphics use the selected capture device's
rotation coordinator to account for its native sensor orientation. Rotation is
applied to the raw graphic before front-camera preview mirroring. The current
foreground window scene's interface orientation is read for each frame, including
after display or interface-orientation changes. Foreground-inactive scenes remain
eligible during system overlays; the last valid orientation is retained across
temporary display activation gaps or unknown scene geometry. Applications presenting multiple
active window scenes should be aware that this API does not take an owning scene.

The photo APIs configure the photo connection's rotation metadata for the physical
device orientation at capture. Decoding applies that metadata once, including when
preserving HDR gain maps; photos are not mirrored like the front-camera preview.
Earlier iOS versions and Mac Catalyst retain the existing rotation behavior.

## Topics

### Camera

- ``Graphic/camera(with:)``
- ``Graphic/camera(device:quality:)``
- ``Graphic/camera(at:lens:quality:)``

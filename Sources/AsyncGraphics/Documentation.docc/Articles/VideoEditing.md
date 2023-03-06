# Video Editing

Edit a video by applying various effects.

## Overview

To edit a video we first need to convert a video to an array of ``Graphic``. Then apply our effect and finally convert the array back to a video.

In this example we create a command line tool. This code will also run in an iOS app, then you can grab the video from your bundle.

> In the command line tool, make sure to rename your swift file to something other than main.swift, as we will be using @main as the entry point.

- First import the video file to a stream of ``Graphic``, by passing the input url to ``Graphic/importVideoStream(url:)``.
- Then loop over all frames and apply the effects you want.
- Finally export the video with ``Graphic/exportVideoToData(with:fps:kbps:format:)`` and write out the data to an output url.

```swift
import Foundation
import AsyncGraphics

@main
struct Main {

    static func main() async throws {
        
        let inputURL = URL(fileURLWithPath: "/Users/username/Desktop/InputVideo.mov")
        
        let videoGraphics: AsyncThrowingStream<Graphic, Error> = Graphic.importVideoStream(url: inputURL)
        var graphics: [Graphic] = []
        
        for try await videoGraphic in videoGraphics {
            let editedGraphic: Graphic = try await videoGraphic
                .blurred(radius: 20)
                .gamma(0.5)
                .brightness(2.0)
            graphics.append(editedGraphic)
        }
        
        let data: Data = try await graphics.exportVideoToData(fps: 30, kbps: 1_000)
        let outputURL = URL(fileURLWithPath: "/Users/username/Desktop/OutputVideo.mov")
        
        try data.write(to: outputURL)
    }
}
```

## Topics

### Video

- ``Graphic/importVideoFrame(at:url:info:)``
- ``Graphic/importVideo(url:progress:)``
- ``Graphic/importVideoStream(url:)``
- ``Graphic/exportVideoToData(with:fps:kbps:format:)``
- ``Graphic/exportVideoToURL(with:fps:kbps:format:)``

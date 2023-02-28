# Video Playback

In this example we create a video player UI with a play / pause button and a slider as a time seeker. 

## Overview

First we create a ``Graphic.VideoPlayer``. The video player takes a url and options. In this case we want the video to loop and be muted.

Then we create a `State` for our current video ``Graphic``. Then in the `body` we add the graphic with ``GraphicView``. 

In the bottom of the `VStack` we add an `HStack` with a play button and a seek slider.

The button will just toggle between playing and pausing the video.

The slider will seek with a binding of the current time and the `videoPlayer.seek(to:)` func.

> Note that the slider is disabled during playback. To properly use seek, please call `videoPlayer.seekStart()` and `videoPlayer.seekEnd()`.

In the bottom of our `body` we add a task, this will render the video frames.

```swift
import SwiftUI
import AsyncGraphics

struct ContentView: View {
   
    @StateObject private var videoPlayer: Graphic.VideoPlayer = {
        let url = Bundle.main.url(forResource: "Video", withExtension: "mov")!
        var options = Graphic.VideoPlayer.Options()
        options.loop = true
        options.volume = 0.0
        return Graphic.VideoPlayer(url: url, options: options)
    }()
    
    @State private var graphic: Graphic?
    
    var body: some View {
        VStack {
            
            if let graphic {
                GraphicView(graphic: graphic)
            }
            
            HStack {
                
                Button {
                    if videoPlayer.playing {
                        videoPlayer.pause()
                    } else {
                        videoPlayer.play()
                    }
                } label: {
                    Image(systemName: videoPlayer.playing ? "pause.fill" : "play.fill")
                }
                
                Slider(value: Binding(get: {
                    videoPlayer.seconds
                }, set: { second in
                    videoPlayer.seek(to: second)
                }), in: 0.0...videoPlayer.info.duration)
                .disabled(videoPlayer.playing)
            }
        }
        .padding()
        .task {
            do {
                for try await videoGraphic in try Graphic.playVideo(with: videoPlayer) {
                    self.graphic = videoGraphic
                }
            } catch {
                print(error)
            }
        }
    }
}
```

## Topics

### Video Playback

- ``Graphic.playVideo``

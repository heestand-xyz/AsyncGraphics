//
//  Created by Anton Heestand on 2022-08-21.
//

import CoreGraphics
import AVFoundation

class VideoController: NSObject {
    
    private let player: AVPlayer
    
    private var timer: Timer?
    
    private let videoOutput: AVPlayerItemVideoOutput
        
    private let loop: Bool
    private let volume: Float
    
    var graphicsHandler: ((Graphic) -> ())?
    var endedHandler: (() -> ())?

    // MARK: Life Cycle
    
    init(url: URL, loop: Bool = false, volume: Float = 1.0) {
        
        self.loop = loop
        self.volume = volume
        
        let attributes = [
            kCVPixelBufferPixelFormatTypeKey as String : Int(kCVPixelFormatType_32BGRA)
        ]
        videoOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: attributes)
        
        let asset = AVURLAsset(url: url)
        
        let item = AVPlayerItem(asset: asset)
        item.add(videoOutput)
        
        player = AVPlayer(playerItem: item)
        
        super.init()
        
        player.volume = volume
        player.actionAtItemEnd = .none
        player.play()
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)
        
        let fps: Float = asset.tracks(withMediaType: .video).first?.nominalFrameRate ?? 30
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / Double(fps), repeats: true, block: { [weak self] _ in
            self?.readBuffer()
        })
    }
    
    func cancel() {
        graphicsHandler = nil
        player.pause()
        timer?.invalidate()
    }
    
    // MARK: Read Buffer
    
    private func readBuffer() {
        
        let currentTime = player.currentItem!.currentTime()
//        let duration = player!.currentItem!.duration.seconds
//        let fraction = currentTime.seconds / duration
        
        guard videoOutput.hasNewPixelBuffer(forItemTime: currentTime),
              let pixelBuffer = videoOutput.copyPixelBuffer(forItemTime: currentTime, itemTimeForDisplay: nil) else {
            return
        }
        
        guard let texture: MTLTexture = try? pixelBuffer.texture(),
              let graphic: Graphic = try? .texture(texture)
        else { return }

        graphicsHandler?(graphic)
    }
    
    // MARK: Loop
    
    @objc private func playerItemDidReachEnd() {
        guard loop else {
            endedHandler?()
            cancel()
            return
        }
        player.seek(to: .zero)
    }
}

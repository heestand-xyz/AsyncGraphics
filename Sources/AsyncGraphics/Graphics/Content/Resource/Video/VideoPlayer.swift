//
//  Created by Anton Heestand on 2023-02-28.
//

import AVKit
import Combine

protocol GraphicVideoPlayerDelegate: AnyObject {
    func play(time: CMTime)
}

extension Graphic {
    
    public class VideoPlayer: ObservableObject {
        
        enum VideoPlayerError: LocalizedError {
            case frameRateNotFound
            var errorDescription: String? {
                switch self {
                case .frameRateNotFound:
                    return "AsyncGraphics - Graphic - VideoPlayer - Frame Rate Not Found"
                }
            }
        }
        
        public struct Options {
            public var loop: Bool = false
            public var volume: Double = 1.0
            public init() {}
        }
        
        public struct Info {
            /// Frames per second
            public let frameRate: Double
            /// Durations in seconds
            public let duration: Double
            /// Number of frames in the video
            public var frameCount: Int {
                Int(duration * frameRate)
            }
        }
        
        weak var delegate: GraphicVideoPlayerDelegate?
        
        let asset: AVURLAsset
        let item: AVPlayerItem
        let player: AVPlayer
        
        public var options: Options {
            didSet {
                updatedOptions()
            }
        }
        
        private var timer: Timer?
        
        private var playing: Bool = false
        
        private var seeking: Bool = false
        private var wasPlaying: Bool = false
        
        public var info: Info
        
        public var time: CMTime {
            player.currentTime()
        }
        
        @Published private var _seconds: Double = 0.0
        public var seconds: Double {
            get { _seconds }
            set { seek(to: newValue) }
        }
        
        @Published private var _frameIndex: Int = 0
        public var frameIndex: Int {
            get { _frameIndex }
            set { seek(to: newValue) }
        }
        
        public init(url: URL, options: Options = .init()) throws {
            
            let asset = AVURLAsset(url: url)
            let item = AVPlayerItem(asset: asset)
            let player = AVPlayer(playerItem: item)
            
            self.asset = asset
            self.item = item
            self.player = player
            self.options = options
            
            guard let frameRate: Float = asset.tracks(withMediaType: .video).first?.nominalFrameRate else {
                throw VideoPlayerError.frameRateNotFound
            }
            let duration: Double = asset.duration.seconds
            self.info =  Info(frameRate: Double(frameRate),
                              duration: duration)
            
            updatedOptions()
            setupNotifications()
        }
        
        deinit {
            stop()
        }
        
        private func startTimer() {
            playFrame()
            timer = .scheduledTimer(withTimeInterval: 1.0 / Double(info.frameRate), repeats: true) { [weak self] _ in
                self?.playFrame()
            }
        }
        
        private func playFrame() {
            delegate?.play(time: time)
            _seconds = time.seconds
            _frameIndex = Int(_seconds * info.frameRate)
        }
        
        private func stopTimer() {
            timer?.invalidate()
            timer = nil
        }
        
        private func setupNotifications() {
            NotificationCenter.default.addObserver(self, selector: #selector(didReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)
        }
        
        private func updatedOptions() {
            player.volume = Float(options.volume)
            player.actionAtItemEnd = options.loop ? .none : .pause
        }
        
        public func play() {
            player.play()
            startTimer()
            playing = true
        }
        
        public func pause() {
            player.pause()
            stopTimer()
            playing = false
        }
        
        public func stop() {
            pause()
            player.seek(to: .zero)
            playFrame()
        }
        
        public func seek(to frameIndex: Int) {
            seek(to: CMTime(value: CMTimeValue(frameIndex), timescale: CMTimeScale(info.frameRate)))
        }
        
        public func seek(to seconds: Double) {
            seek(to: CMTime(seconds: seconds, preferredTimescale: CMTimeScale(info.frameRate)))
        }
        
        public func startSeek() {
            wasPlaying = playing
            pause()
            seeking = true
        }
        
        public func seek(to time: CMTime) {
            if !seeking {
                startSeek()
            }
            player.seek(to: time)
            playFrame()
        }
        
        public func stopSeek() {
            if wasPlaying {
                play()
            }
            seeking = false
            wasPlaying = false
        }
        
        @objc private func didReachEnd() {
            guard options.loop else { return }
            player.seek(to: .zero)
        }
    }
}

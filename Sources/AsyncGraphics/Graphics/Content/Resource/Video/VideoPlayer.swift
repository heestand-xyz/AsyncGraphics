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
            case videoNotFound(name: String)
            var errorDescription: String? {
                switch self {
                case .frameRateNotFound:
                    return "AsyncGraphics - Graphic - VideoPlayer - Frame Rate Not Found"
                case .videoNotFound(let name):
                    return "AsyncGraphics - Graphic - VideoPlayer - Video Not Found \"\(name)\""
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
        
        @Published private var _playing: Bool = false
        public var playing: Bool {
            get { _playing }
            set {
                if newValue {
                    play()
                } else {
                    pause()
                }
            }
        }
        
        private var seeking: Bool = false
        private var wasPlaying: Bool = false
        
        public var info: Info
        
        public var time: CMTime {
            player.currentTime()
        }
        
        @Published public private(set) var seconds: Double = 0.0
        @Published public private(set) var frameIndex: Int = 0
        
        public convenience init(named name: String,
                                fileExtension: String = "mov",
                                in bundle: Bundle = .main,
                                options: Options = .init()) throws {
            guard let url: URL = bundle.url(forResource: name, withExtension: fileExtension) else {
                throw VideoPlayerError.videoNotFound(name: "\(name).\(fileExtension)")
            }
            try self.init(url: url, options: options)
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
        
        private func playFrame() {
            delegate?.play(time: time)
            seconds = time.seconds
            frameIndex = Int(time.seconds * info.frameRate)
        }
        
        private func startTimer() {
            playFrame()
            timer = .scheduledTimer(withTimeInterval: 1.0 / Double(info.frameRate), repeats: true) { [weak self] _ in
                self?.playFrame()
            }
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
            _playing = true
        }
        
        public func pause() {
            player.pause()
            stopTimer()
            _playing = false
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

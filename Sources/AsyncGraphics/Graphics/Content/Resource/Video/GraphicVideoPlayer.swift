//
//  Created by Anton Heestand on 2023-02-28.
//

@preconcurrency import AVKit
import Combine

protocol GraphicVideoPlayerDelegate: AnyObject {
    @MainActor
    func play(time: CMTime)
}

/// Please call ``setup()`` or set ``info-swift.property`` before playing.
@Observable
public final class GraphicVideoPlayer: Sendable {
    
    let id = UUID()
    
    enum VideoPlayerError: LocalizedError {
        case assetNotFound
        case resolutionNotFound
        case videoNotFound(name: String)
        var errorDescription: String? {
            switch self {
            case .assetNotFound:
                return "AsyncGraphics - Graphic - VideoPlayer - Asset Not Found"
            case .resolutionNotFound:
                return "AsyncGraphics - Graphic - VideoPlayer - Resolution Not Found"
            case .videoNotFound(let name):
                return "AsyncGraphics - Graphic - VideoPlayer - Video Not Found \"\(name)\""
            }
        }
    }
    
    public struct Options: Sendable {
        public var loop: Bool = false
        public var volume: Double = 1.0
        public init() {}
    }
    
    public struct Info: Sendable {
        /// Frames per second
        public let frameRate: Double
        /// Durations in seconds
        public let duration: Double
        /// Number of frames in the video
        public var frameCount: Int {
            Int(duration * frameRate)
        }
        /// Resolution in pixels
        public let resolution: CGSize
    }
    
    @MainActor
    weak var delegate: GraphicVideoPlayerDelegate?
    
    let asset: AVURLAsset
    let item: AVPlayerItem
    let player: AVPlayer
    
    let url: URL
    
    @MainActor
    public var options: Options {
        didSet {
            updatedOptions()
        }
    }
    
    @MainActor
    private var timer: Timer?
    
    @MainActor
    private var _playing: Bool = false
    @MainActor
    public var playing: Bool {
        get {
            _playing
        }
        set {
            if newValue {
                play()
            } else {
                pause()
            }
        }
    }
    
    @MainActor
    private var seeking: Bool = false
    @MainActor
    private var wasPlaying: Bool = false
    
    @MainActor
    public private(set) var info: Info?
    
    public var time: CMTime {
        player.currentTime()
    }
    
    @MainActor
    public private(set) var seconds: Double = 0.0
    @MainActor
    public private(set) var frameIndex: Int = 0
    
    /// Please call ``setup()`` or set ``info-swift.property`` before playing.
    @MainActor
    public convenience init(named name: String,
                            fileExtension: String = "mov",
                            in bundle: Bundle = .main,
                            options: Options = .init()) throws {
        guard let url: URL = bundle.url(forResource: name, withExtension: fileExtension) else {
            throw VideoPlayerError.videoNotFound(name: "\(name).\(fileExtension)")
        }
        self.init(url: url, options: options)
    }
    
    /// Please call ``setup()`` or set ``info-swift.property`` before playing.
    @MainActor
    public init(url: URL, options: Options = .init()) {
        
        let asset = AVURLAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: item)
        
        self.asset = asset
        self.item = item
        self.player = player
        self.options = options
        
        self.url = url
        
        updatedOptions()
        setupNotifications()
    }
    
    public func setup() async throws {
        
        guard let track: AVAssetTrack = try await asset.load(.tracks).first(where: { $0.mediaType == .video }) else {
            fatalError(VideoPlayerError.assetNotFound.localizedDescription)
        }
        let frameRate: Double = try await Double(track.load(.nominalFrameRate))
        let duration: Double = try await asset.load(.duration).seconds
        guard let resolution: CGSize = try? await {
            var resolution: CGSize = try await track.load(.naturalSize)
            if resolution == .zero {
                /// Backup method to retrieve the resolution
                let generator: AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
                let firstImage: CGImage
                if #available(iOS 16, macOS 13, visionOS 1.0, *) {
                    let (image, _): (CGImage, CMTime) = try await generator.image(at: .zero)
                    firstImage = image
                } else {
                    #if os(visionOS)
                    fatalError()
                    #else
                    firstImage = try generator.copyCGImage(at: .zero, actualTime: nil)
                    #endif
                }
                resolution = firstImage.size
            }
            return resolution
        }() else {
            fatalError(VideoPlayerError.resolutionNotFound.localizedDescription)
        }
        
        await MainActor.run {
            info = Info(frameRate: frameRate,
                        duration: duration,
                        resolution: resolution)
        }
    }
    
    deinit {
        player.pause()
    }
    
    @MainActor
    private func playFrame() {
        guard let info: Info else {
            print("AsyncGraphics - GraphicVideoPlayer - Can't play - Please call setup or set info first.")
            return
        }
        delegate?.play(time: time)
        seconds = time.seconds
        frameIndex = Int(time.seconds * info.frameRate)
    }
    
    @MainActor
    private func startTimer() {
        guard let info: Info else {
            print("AsyncGraphics - GraphicVideoPlayer - Can't start timer - Please call setup or set info first.")
            return
        }
        playFrame()
        timer = .scheduledTimer(withTimeInterval: 1.0 / Double(info.frameRate), repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.playFrame()
            }
        }
    }
    
    @MainActor
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(didReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)
    }
    
    @MainActor
    private func updatedOptions() {
        player.volume = Float(options.volume)
        player.actionAtItemEnd = options.loop ? .none : .pause
    }
    
    @MainActor
    public func play() {
        player.play()
        startTimer()
    }
    
    @MainActor
    public func pause() {
        player.pause()
        stopTimer()
    }
    
    @MainActor
    public func stop() {
        pause()
        player.seek(to: .zero)
        playFrame()
    }
    
    @MainActor
    public func seek(to frameIndex: Int) {
        guard let info: Info else {
            print("AsyncGraphics - GraphicVideoPlayer - Can't seek - Please call setup or set info first.")
            return
        }
        seek(to: CMTime(value: CMTimeValue(frameIndex), timescale: CMTimeScale(info.frameRate)))
    }
    
    @MainActor
    public func seek(to seconds: Double) {
        guard let info: Info else {
            print("AsyncGraphics - GraphicVideoPlayer - Can't seek - Please call setup or set info first.")
            return
        }
        seek(to: CMTime(seconds: seconds, preferredTimescale: CMTimeScale(info.frameRate * 1_000)))
    }
    
    @MainActor
    public func startSeek() {
        wasPlaying = playing
        pause()
        seeking = true
    }
    
    @MainActor
    public func seek(to time: CMTime) {
        if !seeking {
            startSeek()
        }
        player.seek(to: time)
        playFrame()
    }
    
    @MainActor
    public func stopSeek() {
        if wasPlaying {
            play()
        }
        seeking = false
        wasPlaying = false
    }
    
    @objc private func didReachEnd() {
        Task { @MainActor in
            guard options.loop else { return }
            player.seek(to: .zero)
        }
    }
}

extension GraphicVideoPlayer: Equatable {
    
    public static func == (lhs: GraphicVideoPlayer, rhs: GraphicVideoPlayer) -> Bool {
        lhs.id == rhs.id
    }
}

extension GraphicVideoPlayer: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

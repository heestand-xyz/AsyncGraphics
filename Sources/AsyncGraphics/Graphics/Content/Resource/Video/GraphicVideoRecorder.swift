//
//  Created by Anton Heestand on 2022-05-03.
//

import AVFoundation
import TextureMap

@available(*, deprecated, renamed: "GraphicVideoRecorder")
public typealias GraphicRecorder = GraphicVideoRecorder

/// Record graphics to a video over time
///
/// First call ``start()``.
///
/// Call ``append(graphic:)`` over time.
///
/// When done, call ``stop()-4i1ev``.
///
/// > All appended ``Graphic``s need to have the same resolution.
public class GraphicVideoRecorder {
    
    struct AV {
        let writer: AVAssetWriter
        let input: AVAssetWriterInput
        let adaptor: AVAssetWriterInputPixelBufferAdaptor
        let url: URL
    }
    var av: AV?
    
    private let fps: Double
    private let kbps: Int
    
    public enum VideoCodec: String, CaseIterable {
        case h264
        case proRes
        public var type: AVVideoCodecType {
            switch self {
            case .h264: 
                return .h264
            case .proRes:
                #if os(visionOS)
                print("AsyncGraphics - Warning: ProRes not supported on visionOS. Falling back to h264.")
                return .h264
                #else
                return .proRes4444
                #endif
            }
        }
    }
    private let codec: VideoCodec
    
    public enum VideoFormat: String, CaseIterable {
        case mov
        case mp4
        public var type: AVFileType {
            switch self {
            case .mov: return .mov
            case .mp4: return .mp4
            }
        }
    }
    private let format: VideoFormat
    
    private let resolution: CGSize
    
    private var frameIndex: Int = 0
    
    public var recording: Bool = false
    
    enum RecordError: LocalizedError {
        
        case alreadyStarted
        case startNotCalled
        case noFramesRecorded
        case mismatchResolution
        case isNotReadyForMoreMediaData
        case badWriterState(Int, String?)
        case writerFailed
        case appendFailed
        
        var errorDescription: String? {
            switch self {
            case .alreadyStarted:
                return "AsyncGraphics - GraphicVideoRecorder - Already Started"
            case .startNotCalled:
                return "AsyncGraphics - GraphicVideoRecorder - Start Not Called"
            case .noFramesRecorded:
                return "AsyncGraphics - GraphicVideoRecorder - No Frames Recorded"
            case .mismatchResolution:
                return "AsyncGraphics - GraphicVideoRecorder - Mismatch Resolution"
            case .isNotReadyForMoreMediaData:
                return "AsyncGraphics - GraphicVideoRecorder - Is Not Ready For More Media Data"
            case .badWriterState(let status, let error):
                return "AsyncGraphics - GraphicVideoRecorder - Bad Writer State (\(status))\(error != nil ? "\n\n\(error!)" : "")"
            case .writerFailed:
                return "AsyncGraphics - GraphicVideoRecorder - Writer Failed"
            case .appendFailed:
                return "AsyncGraphics - GraphicVideoRecorder - Append Failed"
            }
        }
    }

    public init(fps: Double = 30.0, kbps: Int = 10_000, format: VideoFormat = .mov, codec: VideoCodec = .h264, resolution: CGSize) {
        self.fps = fps
        self.kbps = kbps
        self.format = format
        self.resolution = resolution
        self.codec = codec
    }
    
    public func start() throws {
        
        guard av == nil else {
            throw RecordError.alreadyStarted
        }
        
        let id = UUID().uuidString.split(separator: "-").first!
        let name: String = "AsyncGraphics_\(id).\(format.rawValue)"
        
        let folderURL: URL = FileManager.default.temporaryDirectory.appendingPathComponent("AsyncGraphics")
        
        try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
        
        let url = folderURL.appendingPathComponent("\(name)")
        
        let writer = try AVAssetWriter(outputURL: url, fileType: format.type)
    
        var settings: [String: Any] = [
            AVVideoCodecKey: codec.type,
            AVVideoWidthKey: resolution.width,
            AVVideoHeightKey: resolution.height,
        ]
        if codec != .proRes {
            let bps: Int = kbps * 1_000
            settings[AVVideoCompressionPropertiesKey] = [AVVideoAverageBitRateKey: bps]
        }
        let input = AVAssetWriterInput(mediaType: .video, outputSettings: settings)
        input.expectsMediaDataInRealTime = true
        
        writer.add(input)
        
        let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: [
            kCVPixelBufferPixelFormatTypeKey as String : Int(kCVPixelFormatType_32ARGB),
            kCVPixelBufferWidthKey as String : resolution.width,
            kCVPixelBufferHeightKey as String : resolution.height,
        ])
        
        writer.startWriting()
        writer.startSession(atSourceTime: .zero)
        
        av = AV(writer: writer, input: input, adaptor: adaptor, url: url)
        
        recording = true
    }
    
    public func append(graphic: Graphic) async throws {
        
        guard let av: AV = av else {
            throw RecordError.startNotCalled
        }
        
        guard av.writer.status == .writing else {
            var errorString: String?
            if let error = av.writer.error {
                errorString = error.localizedDescription + "\n\n" + String(describing: error)
            }
            throw RecordError.badWriterState(av.writer.status.rawValue, errorString)
        }
        
        guard graphic.resolution == resolution else {
            throw RecordError.mismatchResolution
        }
        
        let graphic = try await graphic
            .mirroredVertically()
            .channelMix(red: .blue, blue: .red)

        let pixelBuffer: CVPixelBuffer = try TextureMap.pixelBuffer(texture: graphic.texture, colorSpace: graphic.colorSpace)
        
        let time: CMTime = CMTimeMake(value: Int64(frameIndex * 1_000), timescale: Int32(fps * 1_000.0))

        guard av.adaptor.append(pixelBuffer, withPresentationTime: time) else {
            throw RecordError.appendFailed
        }
        
        frameIndex += 1
    }
 
    public func stop() async throws -> Data {
        
        let url: URL = try await stop()
        
        let data = try Data(contentsOf: url)
        
        try FileManager.default.removeItem(at: url)
        
        return data
    }
    
    public func stop() async throws -> URL {
        
        defer {
            cleanup()
        }
        
        guard let av: AV = av else {
            throw RecordError.startNotCalled
        }
        
        guard frameIndex > 0 else {
            throw RecordError.noFramesRecorded
        }
        
        guard av.input.isReadyForMoreMediaData else {
            throw RecordError.isNotReadyForMoreMediaData
        }
        
        guard av.writer.status != .failed else {
            throw RecordError.writerFailed
        }

        av.input.markAsFinished()
        
        await withCheckedContinuation { continuation in
        
            av.writer.finishWriting {
            
                DispatchQueue.main.async {
                    continuation.resume()
                }
            }
        }
        
        return av.url
    }
    
    public func cancel() {
        cleanup()
    }
    
    private func cleanup() {
        frameIndex = 0
        av = nil
        recording = false
    }
}

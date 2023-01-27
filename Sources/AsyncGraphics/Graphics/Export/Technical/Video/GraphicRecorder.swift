//
//  Created by Anton Heestand on 2022-05-03.
//

import AVFoundation
import TextureMap

/// Record graphics to a video over time
///
/// First call ``start()``.
///
/// Call ``append(graphic:)`` over time.
///
/// When done, call ``stop()-4i1ev``.
///
/// > All appended ``Graphic``s need to have the same resolution.
public class GraphicRecorder {
    
    struct AV {
        let writer: AVAssetWriter
        let input: AVAssetWriterInput
        let adaptor: AVAssetWriterInputPixelBufferAdaptor
        let url: URL
    }
    var av: AV?
    
    private let fps: Double
    private let kbps: Int
    
    public enum VideoFormat: String, CaseIterable {
        case mov
        case mp4
        public var fileType: AVFileType {
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
        case writerFailed
        case appendFailed
        
        var errorDescription: String? {
            switch self {
            case .alreadyStarted:
                return "AsyncGraphics - GraphicRecorder - Already Started"
            case .startNotCalled:
                return "AsyncGraphics - GraphicRecorder - Start Not Called"
            case .noFramesRecorded:
                return "AsyncGraphics - GraphicRecorder - No Frames Recorded"
            case .mismatchResolution:
                return "AsyncGraphics - GraphicRecorder - Mismatch Resolution"
            case .isNotReadyForMoreMediaData:
                return "AsyncGraphics - GraphicRecorder - Is Not Ready For More Media Data"
            case .writerFailed:
                return "AsyncGraphics - GraphicRecorder - Writer Failed"
            case .appendFailed:
                return "AsyncGraphics - GraphicRecorder - Append Failed"
            }
        }
    }

    public init(fps: Double = 30.0, kbps: Int = 10_000, format: VideoFormat = .mov, resolution: CGSize) {
        self.fps = fps
        self.kbps = kbps
        self.format = format
        self.resolution = resolution
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
        
        let writer = try AVAssetWriter(outputURL: url, fileType: format.fileType)

        let bps: Int = kbps * 1_000
        
        let input = AVAssetWriterInput(mediaType: .video, outputSettings: [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: resolution.width,
            AVVideoHeightKey: resolution.height,
            AVVideoCompressionPropertiesKey: [
                AVVideoAverageBitRateKey: bps
            ],
        ])
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

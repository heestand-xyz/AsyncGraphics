//
//  Created by Anton Heestand on 2022-05-03.
//

#if !os(tvOS)

@preconcurrency import AVFoundation
import TextureMap
import VideoToolbox

/// Record graphic pairs to a stereoscopic mv-hevc video over time
///
/// First call ``start()``.
///
/// Call ``append(leftGraphic:rightGraphic)`` over time.
///
/// When done, call ``stop()-4i1ev``.
///
/// > All appended ``Graphic``s need to have the same resolution.
public actor StereoscopicGraphicVideoRecorder: GraphicVideoRecordable {
    
    struct AV: @unchecked Sendable {
        let writer: AVAssetWriter
        let input: AVAssetWriterInput
        let adaptor: AVAssetWriterInputTaggedPixelBufferGroupAdaptor
        let session: VTPixelTransferSession
        let url: URL
    }
    var av: AV?
    
    private let fps: Double
    private let kbps: Int
    
    private let resolution: CGSize
    
    private var frameIndex: Int = 0
    
    public private(set) var recording: Bool = false
    private var appending: Bool = false
    private var stopping: Bool = false
    
    public struct SpatialMetadata: Sendable {
        /// The baseline (distance between the centers of the two cameras), in millimeters.
        public var baselineInMillimeters: Double = 64.0
        /// The horizontal field of view of each camera, in degrees.
        public var horizontalFOV: Double = 60.0
        /// A horizontal presentation adjustment to apply as a fraction of the image width (-1...1).
        public var disparityAdjustment: Double = 0.0
        @MainActor
        public static let `default` = SpatialMetadata()
    }
    public var spatialMetadata: SpatialMetadata?
    
    enum RecordError: LocalizedError {
        
        case alreadyStarted
        case settingsFailedToApply
        case failedToCreateSession
        case startNotCalled
        case noFramesRecorded
        case mismatchResolution
        case failedToGetImageBuffer
        case isNotReadyForMoreMediaData
        case badWriterState(Int, String?)
        case writerFailed
        case appendFailed
        case currentlyAppending
        case bufferPoolNotFound
        case failedToConvertFrame(code: Int)
        
        var errorDescription: String? {
            switch self {
            case .alreadyStarted:
                return "AsyncGraphics - StereoscopicGraphicVideoRecorder - Already Started"
            case .settingsFailedToApply:
                return "AsyncGraphics - StereoscopicGraphicVideoRecorder - Settings Failed to Apply"
            case .failedToCreateSession:
                return "AsyncGraphics - StereoscopicGraphicVideoRecorder - Failed to Create Session"
            case .startNotCalled:
                return "AsyncGraphics - StereoscopicGraphicVideoRecorder - Start Not Called"
            case .noFramesRecorded:
                return "AsyncGraphics - StereoscopicGraphicVideoRecorder - No Frames Recorded"
            case .mismatchResolution:
                return "AsyncGraphics - StereoscopicGraphicVideoRecorder - Mismatch Resolution"
            case .failedToGetImageBuffer:
                return "AsyncGraphics - StereoscopicGraphicVideoRecorder - Failed to Get Image Buffer"
            case .isNotReadyForMoreMediaData:
                return "AsyncGraphics - StereoscopicGraphicVideoRecorder - Is Not Ready For More Media Data"
            case .badWriterState(let status, let error):
                return "AsyncGraphics - StereoscopicGraphicVideoRecorder - Bad Writer State (\(status))\(error != nil ? "\n\n\(error!)" : "")"
            case .writerFailed:
                return "AsyncGraphics - StereoscopicGraphicVideoRecorder - Writer Failed"
            case .appendFailed:
                return "AsyncGraphics - StereoscopicGraphicVideoRecorder - Append Failed"
            case .currentlyAppending:
                return "AsyncGraphics - StereoscopicGraphicVideoRecorder - Currently Appending"
            case .bufferPoolNotFound:
                return "AsyncGraphics - StereoscopicGraphicVideoRecorder - Buffer Pool Not Found"
            case .failedToConvertFrame(let code):
                return "AsyncGraphics - StereoscopicGraphicVideoRecorder - Failed to Convert Frame with Code \(code)"
            }
        }
    }

    public init(fps: Double = 30.0, kbps: Int = 10_000, spatialMetadata: SpatialMetadata? = nil, resolution: CGSize) {
        self.fps = fps
        self.kbps = kbps
        self.spatialMetadata = spatialMetadata
        self.resolution = resolution
    }
    
    public func start() throws {
        
        guard av == nil else {
            throw RecordError.alreadyStarted
        }
        
        let id = UUID().uuidString.split(separator: "-").first!
        let name: String = "AsyncGraphics_\(id).mov"
        
        let folderURL: URL = FileManager.default.temporaryDirectory.appendingPathComponent("AsyncGraphics")
        
        try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
        
        let url = folderURL.appendingPathComponent("\(name)")
        
        let writer = try AVAssetWriter(outputURL: url, fileType: AVFileType.mov)
        
        let bps: Int = kbps * 1_000
        
        var multiviewCompressionProperties: [CFString: Any] = [
            kVTCompressionPropertyKey_MVHEVCVideoLayerIDs: [0, 1],
            kVTCompressionPropertyKey_MVHEVCViewIDs: [0, 1],
            kVTCompressionPropertyKey_MVHEVCLeftAndRightViewIDs: [0, 1],
            kVTCompressionPropertyKey_HasLeftStereoEyeView: true,
            kVTCompressionPropertyKey_HasRightStereoEyeView: true,
            AVVideoAverageBitRateKey as CFString: bps
        ]

        if let spatialMetadata {

            let baselineInMicrometers = UInt32(1000.0 * spatialMetadata.baselineInMillimeters)
            let encodedHorizontalFOV = UInt32(1000.0 * spatialMetadata.horizontalFOV)
            let encodedDisparityAdjustment = Int32(10_000.0 * spatialMetadata.disparityAdjustment)

            if #available(iOS 18.0, macOS 15.0, visionOS 2.0, *) {
                multiviewCompressionProperties[kVTCompressionPropertyKey_ProjectionKind] = kCMFormatDescriptionProjectionKind_Rectilinear
            }
            multiviewCompressionProperties[kVTCompressionPropertyKey_StereoCameraBaseline] = baselineInMicrometers
            if #available(iOS 17.4, macOS 14.4, visionOS 1.1, *) {
                multiviewCompressionProperties[kVTCompressionPropertyKey_HorizontalFieldOfView] = encodedHorizontalFOV
            }
            multiviewCompressionProperties[kVTCompressionPropertyKey_HorizontalDisparityAdjustment] = encodedDisparityAdjustment
        }
    
        let settings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.hevc,
            AVVideoWidthKey: resolution.width,
            AVVideoHeightKey: resolution.height,
            AVVideoCompressionPropertiesKey: multiviewCompressionProperties
        ]
        
        guard writer.canApply(outputSettings: settings, forMediaType: AVMediaType.video) else {
            throw RecordError.settingsFailedToApply
        }
        
        let input = AVAssetWriterInput(mediaType: .video, outputSettings: settings)
        input.expectsMediaDataInRealTime = true
        
        writer.add(input)
        
        let sourcePixelAttributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String : Int(kCVPixelFormatType_32ARGB),
            kCVPixelBufferWidthKey as String : resolution.width,
            kCVPixelBufferHeightKey as String : resolution.height,
        ]

        let adaptor = AVAssetWriterInputTaggedPixelBufferGroupAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: sourcePixelAttributes)
        
        writer.startWriting()
        writer.startSession(atSourceTime: .zero)
        
        var session: VTPixelTransferSession? = nil
        guard VTPixelTransferSessionCreate(allocator: kCFAllocatorDefault, pixelTransferSessionOut: &session) == noErr, let session else {
            throw RecordError.failedToCreateSession
        }
        
        av = AV(writer: writer, input: input, adaptor: adaptor, session: session, url: url)
        
        recording = true
    }
    
    public func append(leftGraphic: Graphic, rightGraphic: Graphic) async throws {
        
        if stopping { return }
        if !recording { return }
        
        if appending {
            throw RecordError.currentlyAppending
        }
        
        appending = true
        defer {
            appending = false
        }
        
        guard let av: AV else {
            throw RecordError.startNotCalled
        }
        
        guard av.writer.status == .writing else {
            var errorString: String?
            if let error = av.writer.error {
                errorString = error.localizedDescription + "\n\n" + String(describing: error)
            }
            throw RecordError.badWriterState(av.writer.status.rawValue, errorString)
        }
        
        guard leftGraphic.resolution == resolution,
              rightGraphic.resolution == resolution else {
            throw RecordError.mismatchResolution
        }
        
        // TODO: Optimize flipping of axis and colors...
        let leftGraphic = try await leftGraphic
            .mirroredVertically()
            .channelMix(red: .blue, blue: .red)
        let rightGraphic = try await rightGraphic
            .mirroredVertically()
            .channelMix(red: .blue, blue: .red)

        let leftImageBuffer: CMSampleBuffer = try TextureMap.sampleBuffer(
            texture: leftGraphic.texture,
            colorSpace: leftGraphic.colorSpace
        )
        let rightImageBuffer: CMSampleBuffer = try TextureMap.sampleBuffer(
            texture: rightGraphic.texture,
            colorSpace: rightGraphic.colorSpace
        )
        guard let leftImageBuffer = CMSampleBufferGetImageBuffer(leftImageBuffer) else {
            throw RecordError.failedToGetImageBuffer
        }
        guard let rightImageBuffer = CMSampleBufferGetImageBuffer(rightImageBuffer) else {
            throw RecordError.failedToGetImageBuffer
        }
        
        guard let pixelBufferPool = av.adaptor.pixelBufferPool else {
            throw RecordError.bufferPoolNotFound
        }
        
        let leftTaggedBuffer = try Self.tagBuffer(eyeIndex: 0, from: leftImageBuffer, with: pixelBufferPool, in: av.session)
        let rightTaggedBuffer = try Self.tagBuffer(eyeIndex: 1, from: rightImageBuffer, with: pixelBufferPool, in: av.session)
        
        let time: CMTime = CMTimeMake(value: Int64(frameIndex * 1_000), timescale: Int32(fps * 1_000.0))

        guard av.adaptor.appendTaggedBuffers([leftTaggedBuffer, rightTaggedBuffer], withPresentationTime: time) else {
            throw RecordError.appendFailed
        }
        
        frameIndex += 1
    }
    
    private static func tagBuffer(
        eyeIndex: Int,
        from imageBuffer: CVImageBuffer,
        with pixelBufferPool: CVPixelBufferPool,
        in session: VTPixelTransferSession
    ) throws -> CMTaggedBuffer {
        
        var pixelBuffer: CVPixelBuffer?
        CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pixelBufferPool, &pixelBuffer)
        guard let pixelBuffer else {
            throw RecordError.failedToConvertFrame(code: 0)
        }
        
        guard VTPixelTransferSessionTransferImage(session, from: imageBuffer, to: pixelBuffer) == noErr else {
            throw RecordError.failedToConvertFrame(code: 1)
        }

        let eye: CMStereoViewComponents = eyeIndex == 0 ? .leftEye : .rightEye
        let tags: [CMTag] = [.videoLayerID(Int64(eyeIndex)), .stereoView(eye)]
        return CMTaggedBuffer(tags: tags, buffer: .pixelBuffer(pixelBuffer))
    }
 
    public func stop() async throws -> Data {
        
        let url: URL = try await stop()
        
        let data = try Data(contentsOf: url)
        
        try FileManager.default.removeItem(at: url)
        
        return data
    }
    
    public func stop() async throws -> URL {
        
        stopping = true
        
        defer {
            cleanup()
            stopping = false
        }
        
        guard let av: AV else {
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
            
                continuation.resume()
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

#endif

import Vision
import TextureMap
import CoreGraphicsExtensions

extension Graphic {
    
    @EnumMacro
    public enum SaliencyType: String, GraphicEnum {
        case attention
        case objectness
    }
    
    enum SaliencyError: LocalizedError {
        case noResults
        var errorDescription: String? {
            switch self {
            case .noResults:
                return "AsyncGraphics - Saliency - No Results"
            }
        }
    }

    /// Detect attention or objectness of a graphic, as a monochrome heat map.
    @available(iOS 18.0, tvOS 18.0, macOS 15.0, visionOS 2.0, *)
    public func saliency(of saliencyType: SaliencyType) async throws -> Graphic {
        
        try await rawSaliency(of: saliencyType)
            .resized(to: resolution, placement: .stretch)
    }
    
    /// Detect raw attention or objectness of a graphic, as a monochrome heat map, without resizing resolution of result.
    @available(iOS 18.0, tvOS 18.0, macOS 15.0, visionOS 2.0, *)
    public func rawSaliency(of saliencyType: SaliencyType) async throws -> Graphic {
        
        let observation: SaliencyImageObservation = try await saliencyObservation(of: saliencyType)
        
        let maskGraphic: Graphic = try await .image(observation.heatMap.cgImage)
            .channelMix(green: .red, blue: .red, alpha: .red)
        
        return maskGraphic
    }
    
    /// Detect frames of attention or objectness of a graphic.
    @available(iOS 18.0, tvOS 18.0, macOS 15.0, visionOS 2.0, *)
    public func saliencyFrames(of saliencyType: SaliencyType) async throws -> [CGRect] {
        
        let observation: SaliencyImageObservation = try await saliencyObservation(of: saliencyType)
        
        return observation.salientObjects.map { object in
            object.boundingBox.cgRect * resolution
        }
    }
    
    @available(iOS 18.0, tvOS 18.0, macOS 15.0, visionOS 2.0, *)
    private func saliencyObservation(of saliencyType: SaliencyType) async throws -> SaliencyImageObservation {
        
        let cgImage: CGImage = try await cgImage
        
        return try await withCheckedThrowingContinuation { continuation in
           
            func process(request: VNRequest, error: Error?) {
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let observation = request.results?.first as? SaliencyImageObservation else {
                    continuation.resume(throwing: SaliencyError.noResults)
                    return
                }
                continuation.resume(returning: observation)
            }
            
            let request: VNRequest = switch saliencyType {
            case .attention:
                VNGenerateAttentionBasedSaliencyImageRequest { (request, error) in
                    process(request: request, error: error)
                }
            case .objectness:
                VNGenerateObjectnessBasedSaliencyImageRequest { (request, error) in
                    process(request: request, error: error)
                }
            }

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}

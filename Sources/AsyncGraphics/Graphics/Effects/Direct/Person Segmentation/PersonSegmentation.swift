import Vision
import TextureMap

extension Graphic {
    
    enum PersonSegmentationError: LocalizedError {
        case noResults
        var errorDescription: String? {
            switch self {
            case .noResults:
                return "AsyncGraphics - Person Segmentation - No Results"
            }
        }
    }

    public func personSegmentation() async throws -> Graphic {
        let mask: Graphic = try await personSegmentationMask()
        return try await blended(with: mask.luminanceToAlpha(),
                                 blendingMode: .multiply,
                                 placement: .stretch)
    }
    
    public func personSegmentationMask() async throws -> Graphic {
        
        let cgImage: CGImage = try cgImage
        
        let maskPixelBuffer: CVPixelBuffer = try await withCheckedThrowingContinuation { continuation in
           
            let request = VNGeneratePersonSegmentationRequest { (request, error) in
                
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let observation = request.results?.first as? VNPixelBufferObservation else {
                    continuation.resume(throwing: PersonSegmentationError.noResults)
                    return
                }
                
                continuation.resume(returning: observation.pixelBuffer)
            }

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            DispatchQueue.global(qos: .userInteractive).async {
                do {
                    try handler.perform([request])
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
        let maskGraphic: Graphic = try await .pixelBuffer(maskPixelBuffer)
            .channelMix(green: .red, blue: .red, alpha: .red)
            .mirroredVertically()
        
        return maskGraphic
    }
}

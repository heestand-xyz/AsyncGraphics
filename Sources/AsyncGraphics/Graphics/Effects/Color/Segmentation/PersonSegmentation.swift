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

    /// Remove the background of the current ``Graphic``
    public func personSegmentation() async throws -> Graphic {
        try await blended(with: rawPersonSegmentationMask(),
                          blendingMode: .multiply,
                          placement: .stretch)
    }
    
    public func personSegmentationMask() async throws -> Graphic {
        
        try await rawPersonSegmentationMask()
            .resized(to: resolution, placement: .stretch)
    }
    
    private func rawPersonSegmentationMask() async throws -> Graphic {
        
        let cgImage: CGImage = try await cgImage
        
        let maskPixelBuffer: CVPixelBuffer = try await withCheckedThrowingContinuation { continuation in
           
            let request = VNGeneratePersonSegmentationRequest { (request, error) in
                
                guard error == nil else { return }

                guard let observation = request.results?.first as? VNPixelBufferObservation else {
                    continuation.resume(throwing: PersonSegmentationError.noResults)
                    return
                }
                
                continuation.resume(returning: observation.pixelBuffer)
            }

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
        let maskGraphic: Graphic = try await .pixelBuffer(maskPixelBuffer)
            .channelMix(green: .red, blue: .red, alpha: .red)
        
        return maskGraphic
    }
}

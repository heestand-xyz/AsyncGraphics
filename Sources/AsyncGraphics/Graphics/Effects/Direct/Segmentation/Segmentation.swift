//import Vision
//import TextureMap
//
//extension Graphic {
//
//    func segmentedPerson() async throws -> Graphic {
//
//    }
//
//    private func applyMask(maskImage: TMImage, to image: TMImage) -> TMImage? {
//        guard let maskCGImage = maskImage.cgImage, let imageCGImage = image.cgImage else { return nil }
//
//        let mask = CGImage(maskWidth: maskCGImage.width, height: maskCGImage.height, bitsPerComponent: maskCGImage.bitsPerComponent, bitsPerPixel: maskCGImage.bitsPerPixel, bytesPerRow: maskCGImage.bytesPerRow, provider: maskCGImage.dataProvider!, decode: nil, shouldInterpolate: true)
//
//        if let maskedImageRef = imageCGImage.masking(mask!) {
//            return TMImage(cgImage: maskedImageRef)
//        }
//
//        return nil
//    }
//
//    private func performPersonSegmentationRequest(on image: TMImage) {
//        guard let cgImage = image.cgImage else {
//            print("Error: Couldn't convert TMImage to CGImage.")
//            return
//        }
//
//        let request = VNGeneratePersonSegmentationRequest { (request, error) in
//            if let error = error {
//                print("Error: \(error.localizedDescription)")
//                return
//            }
//
//            guard let observation = request.results?.first as? VNSegmentationObservation else {
//                print("Error: No results found.")
//                return
//            }
//
//            // Process the segmentation observation
//            self.processSegmentationObservation(observation, for: image)
//        }
//
//        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
//        do {
//            try handler.perform([request])
//        } catch {
//            print("Error: Failed to perform request: \(error.localizedDescription)")
//        }
//    }
//
//    private func processSegmentationObservation(_ observation: VNSegmentationObservation, for image: TMImage) {
//        guard let maskImage = observation.createMaskImage() else {
//            print("Error: Couldn't create mask image from observation.")
//            return
//        }
//
//        let maskedImage = applyMask(maskImage: maskImage, to: image)
//
//        // Do something with the masked image, e.g., update an image view
//        // imageView.image = maskedImage
//    }
//}
//
//extension VNSegmentationObservation {
//    func createMaskImage() -> TMImage? {
//        guard let pixelBuffer = self.pixelBuffer else { return nil }
//        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
//        let context = CIContext(options: nil)
//        if let cgImage = context.createCGImage(ciImage, from: CGRect(origin: .zero, size: CGSize(width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer)))) {
//            return TMImage(cgImage: cgImage)
//        }
//        return nil
//    }
//}

import SwiftUI
import TextureMap

@available(iOS 16.0, tvOS 16.0, macOS 13.0, *)
extension Graphic {
    
    enum ViewError: LocalizedError {
        case viewRenderFailed
        var errorDescription: String? {
            switch self {
            case .viewRenderFailed:
                return "AsyncGraphics - Graphic - View Render Failed"
            }
        }
    }
    
    public static func view<Content: View>(content: () -> Content) async throws -> Graphic {
        let renderer = await ImageRenderer<Content>(content: content())
        guard let cgImage: CGImage = await renderer.cgImage else {
            throw ViewError.viewRenderFailed
        }
        // Hack to get around a bug
//        let ciImage = TextureMap.ciImage(cgImage: cgImage)
//        cgImage = try TextureMap.cgImage(ciImage: ciImage, colorSpace: .displayP3)
        return try await .image(cgImage)
    }
    
    public static func view<Content: View>(resolution: CGSize, 
                                           alignment: SwiftUI.Alignment = .center,
                                           content: () -> Content) async throws -> Graphic {
        let renderer = await ImageRenderer(
            content: content()
                .frame(width: resolution.width,
                       height: resolution.height,
                       alignment: alignment)
        )
//        var cgImage: CGImage!
//        await renderer.render { size, render in
//            guard let context = CGContext(
//                    data: nil,
//                    width: Int(size.width),
//                    height: Int(size.height),
//                    bitsPerComponent: 8,
//                    bytesPerRow: 0,
//                    space: CGColorSpaceCreateDeviceRGB(),
//                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
//            ) else { return }
//            render(context)
//            cgImage = context.makeImage()
//        }
        guard let cgImage: CGImage = await renderer.cgImage else {
            throw ViewError.viewRenderFailed
        }
        // Hack to get around a bug
//        let ciImage = TextureMap.ciImage(cgImage: cgImage)
//        cgImage = try TextureMap.cgImage(ciImage: ciImage, colorSpace: .displayP3)
        return try await .image(cgImage)
    }
}

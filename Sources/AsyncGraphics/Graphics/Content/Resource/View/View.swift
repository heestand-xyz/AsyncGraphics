import SwiftUI
import TextureMap

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
    
    public static func view<Content: View>(
        content: () -> Content
    ) async throws -> Graphic {
        let renderer = await ImageRenderer<Content>(content: content())
        guard let cgImage: CGImage = await renderer.cgImage else {
            throw ViewError.viewRenderFailed
        }
        return try .texture(TextureMap.textureViaContext(cgImage: cgImage))
    }
    
    public static func view<Content: View>(
        resolution: CGSize,
        alignment: SwiftUI.Alignment = .center,
        content: () -> Content
    ) async throws -> Graphic {
        let renderer = await ImageRenderer(
            content: content()
                .frame(width: resolution.width,
                       height: resolution.height,
                       alignment: alignment)
        )
        guard let cgImage: CGImage = await renderer.cgImage else {
            throw ViewError.viewRenderFailed
        }
        return try .texture(TextureMap.textureViaContext(cgImage: cgImage))
    }
}

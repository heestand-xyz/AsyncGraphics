import SwiftUI
import TextureMap

extension ImageRenderer: @retroactive Sendable where Content: Sendable {}

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
        return try await view(renderer: renderer)
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
        return try await view(renderer: renderer)
    }
    
    private static func view<Content: View>(renderer: ImageRenderer<Content>) async throws -> Graphic {
        guard let cgImage: CGImage = await renderer.cgImage else {
            throw ViewError.viewRenderFailed
        }
        return try await .image(cgImage)
//        return try .texture(TextureMap.textureViaContext(cgImage: cgImage))
    }
}

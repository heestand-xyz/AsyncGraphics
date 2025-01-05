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
    
    @MainActor
    public static func view<Content: View>(
        content: @MainActor () -> Content
    ) async throws -> Graphic {
        let renderer = ImageRenderer<Content>(content: content())
        return try await view(renderer: renderer)
    }
    
    @MainActor
    public static func view<Content: View>(
        resolution: CGSize,
        alignment: SwiftUI.Alignment = .center,
        content: @MainActor () -> Content
    ) async throws -> Graphic {
        let renderer = ImageRenderer(
            content: content()
                .frame(width: resolution.width,
                       height: resolution.height,
                       alignment: alignment)
        )
        return try await view(renderer: renderer)
    }
    
    @MainActor
    private static func view<Content: View>(renderer: ImageRenderer<Content>) async throws -> Graphic {
        guard let cgImage: CGImage = renderer.cgImage else {
            throw ViewError.viewRenderFailed
        }
        return try await .image(cgImage)
//        return try .texture(TextureMap.textureViaContext(cgImage: cgImage))
    }
}

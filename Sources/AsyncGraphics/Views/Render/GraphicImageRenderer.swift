import Foundation
import SwiftUI
import Spatial
import Observation
import CoreGraphicsExtensions
import TextureMap

@MainActor
@Observable
public final class GraphicImageRenderer: Sendable {
    
#if os(visionOS)
    public static let defaultScale: CGFloat = 1.0
#else
    public static let defaultScale: CGFloat = .pixelsPerPoint
#endif
    public var scale: CGFloat = GraphicImageRenderer.defaultScale
    
    public var interpolation: Graphic.ViewInterpolation = .linear
    
    var resolution: CGSize?
    
    var viewSize: CGSize?
    
    var viewResolution: CGSize? {
        guard let viewSize: CGSize else { return nil }
        guard let resolution: CGSize else { return nil }
        return CGSize(width: resolution.width, height: resolution.height)
            .place(in: viewSize * scale,
                   placement: .fit)
    }
    
    struct Display {
        var id: UUID
        let resolution: CGSize
    }
    private var display: Display?
    
    var image: Image?
    
    public init() {}
    
    public func display(graphic: Graphic) async throws {
        
        if resolution != graphic.resolution {
            await MainActor.run {
                resolution = graphic.resolution
            }
        }
        
        try await render(graphic: graphic)
    }
    
    public enum RenderError: String, Error {
        case renderFailed
        case viewNotReady
    }
    
    private func render(graphic: Graphic) async throws {

        guard let viewResolution: CGSize else {
            throw RenderError.viewNotReady
        }
        
        var graphic: Graphic = graphic
            
        if interpolation != .linear {
            
            switch interpolation {
            case .nearestNeighbor:
                graphic = try await graphic
                    .resized(to: viewResolution,
                             placement: .stretch,
                             options: .interpolateNearest)
            case .lanczos, .bilinear:
                let method: Graphic.ResizeMethod = interpolation == .lanczos ? .lanczos : .bilinear
                graphic = try await graphic
                    .resized(to: viewResolution,
                             placement: .stretch,
                             method: method)
            case .linear:
                break
            }
        }
        
        try Task.checkCancellation()
        
        let tmImage: TMImage = try await graphic.sendableImage.receive()
        let image = Image(tmImage: tmImage)
        
        try Task.checkCancellation()
        
        await MainActor.run {
            self.image = image
        }
        
        display = Display(id: graphic.id,
                          resolution: graphic.resolution)
    }
    
    public func hide() {
        resolution = nil
        display = nil
        image = nil
    }
}

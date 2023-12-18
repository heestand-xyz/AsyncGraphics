import Foundation
import SwiftUI
import Spatial
import Observation
import CoreGraphicsExtensions
import TextureMap

@Observable
public final class Graphic3DImageRenderer {
    
#if os(visionOS)
    public static let defaultScale: CGFloat = 1.0
#else
    public static let defaultScale: CGFloat = .pixelsPerPoint
#endif
    var scale: CGFloat = Graphic3DImageRenderer.defaultScale
    
    var interpolation: ViewInterpolation = .linear
    
    var resolution: Size3D?
    
    var viewSize: CGSize?
    
    var viewResolution: CGSize? {
        guard let viewSize: CGSize else { return nil }
        guard let resolution: Size3D else { return nil }
        return CGSize(width: resolution.width, height: resolution.height)
            .place(in: viewSize * scale,
                   placement: .fit)
    }
    
    struct Display {
        var id: UUID
        let resolution: CGSize
    }
    private var display: Display?
    
    var images: [Image] = []
    
    public init() {}
    
    public func display(graphic3D: Graphic3D) async throws {
        
        if resolution != graphic3D.resolution {
            await MainActor.run {
                resolution = graphic3D.resolution
            }
        }
        
        try await render(graphic3D: graphic3D)
    }
    
    enum RenderError: String, Error {
        case renderFailed
        case viewNotReady
    }
    
    private func render(graphic3D: Graphic3D) async throws {

        guard let viewResolution: CGSize else {
            throw RenderError.viewNotReady
        }
        
        var viewGraphics: [Graphic] = try await graphic3D.samples()
        
        if interpolation != .linear,
           CGSize(width: graphic3D.width, height: graphic3D.height) != viewResolution {
    
            viewGraphics = try await withThrowingTaskGroup(of: (Int, Graphic).self) { [weak self] group in
                
                guard let self else { return [] }
                
                for (index, graphic) in viewGraphics.enumerated() {
                    
                    group.addTask {
                        
                        var graphic: Graphic = graphic
                        
                        switch self.interpolation {
                        case .nearestNeighbor:
                            graphic = try await graphic
                                .resized(to: viewResolution,
                                         placement: .stretch,
                                         options: .interpolateNearest)
                        case .lanczos, .bilinear:
                            let method: Graphic.ResizeMethod = self.interpolation == .lanczos ? .lanczos : .bilinear
                            graphic = try await graphic
                                .resized(to: viewResolution,
                                         placement: .stretch,
                                         method: method)
                        case .linear:
                            break
                        }
                        return (index, graphic)
                    }
                }
            
                var graphics: [Graphic?] = Array(repeating: nil, count: viewGraphics.count)
                for try await (index, graphic) in group {
                    graphics[index] = graphic
                }
                return graphics.compactMap { $0 }
            }
        }
        
        let images: [Image] = try await withThrowingTaskGroup(of: (Int, Image).self) { group in
            
            for (index, graphic) in viewGraphics.enumerated() {
                
                group.addTask {
                    let tmImage: TMImage = try await graphic.image
                    let image = Image(tmImage: tmImage)
                    return (index, image)
                }
            }
            
            var images: [Image?] = Array(repeating: nil, count: viewGraphics.count)
            for try await (index, image) in group {
                images[index] = image
            }
            return images.compactMap { $0 }
        }
        
        await MainActor.run {
            self.images = images
        }
        
        display = Display(id: graphic3D.id,
                          resolution: viewGraphics.first!.resolution)
    }
    
    public func hide() {
        resolution = nil
        display = nil
        images = []
    }
}

import Foundation
import Spatial
import Observation
import CoreGraphicsExtensions

#if os(visionOS)

@Observable
public final class Graphic3DViewRenderer {
    
    public var interpolation: Graphic.ViewInterpolation = .linear
    public let extendedDynamicRange: Bool = false
    
    var resolution: Size3D?
    
    var viewSize: CGSize?
    
    var viewResolution: CGSize? {
        guard let viewSize: CGSize else { return nil }
        guard let resolution: Size3D else { return nil }
        #if os(visionOS)
        let scale: CGFloat = 1.0
        #else
        let scale: CGFloat = .pixelsPerPoint
        #endif
        return CGSize(width: resolution.width, height: resolution.height)
            .place(in: viewSize * scale,
                   placement: .fit)
    }
    
    struct Display {
        var id: UUID
        let resolution: CGSize
    }
    private var display: Display?
    
    var renderInView: [Int: (Graphic) async -> Bool] = [:]
    
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
        
        if CGSize(width: graphic3D.width, height: graphic3D.height) != viewResolution {
    
            viewGraphics = try await withThrowingTaskGroup(of: (Int, Graphic).self) { [weak self] group in
                
                guard let self else { return [] }
                
                for (index, graphic) in viewGraphics.enumerated() {
                    
                    group.addTask {
                        
                        var graphic: Graphic = graphic
                        
                        switch self.interpolation {
                        case .linear, .nearestNeighbor:
                            var options: Graphic.EffectOptions = []
                            if self.interpolation == .nearestNeighbor {
                                options.insert(.interpolateNearest)
                            }
                            graphic = try await graphic
                                .resized(to: viewResolution,
                                         placement: .stretch,
                                         options: options)
                        case .lanczos, .bilinear:
                            let method: Graphic.ResizeMethod = self.interpolation == .lanczos ? .lanczos : .bilinear
                            graphic = try await graphic
                                .resized(to: viewResolution,
                                         placement: .stretch,
                                         method: method)
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
        
        display = Display(id: graphic3D.id,
                          resolution: viewGraphics.first!.resolution)
        
        try await withThrowingTaskGroup(of: Void.self) { group in
            
            for (index, render) in renderInView {
                guard viewGraphics.indices.contains(index) else { continue }
                let graphic: Graphic = viewGraphics[index]
                
                group.addTask {
                    let success = await render(graphic)
                    if !success {
                        throw RenderError.renderFailed
                    }
                }
            }
            
            try await group.waitForAll()
        }
    }
    
    public func hide() {
        resolution = nil
        display = nil
    }
}

#endif

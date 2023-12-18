import Foundation
import Observation
import CoreGraphicsExtensions

@Observable
public final class Graphic3DViewRenderer {
    
    public var interpolation: ViewInterpolation = .linear {
        didSet {
            Task {
                try? await render()
            }
        }
    }
    public let extendedDynamicRange: Bool = false
    
    var sourceGraphic: Graphic3D?
    
    var viewSize: CGSize? {
        didSet {
            Task {
                try? await render()
            }
        }
    }
    
    var viewResolution: CGSize? {
        guard let viewSize: CGSize else { return nil }
        guard let sourceGraphic: Graphic3D else { return nil }
        #if os(visionOS)
        let scale: CGFloat = 1.0
        #else
        let scale: CGFloat = .pixelsPerPoint
        #endif
        return CGSize(width: sourceGraphic.width, height: sourceGraphic.height)
            .place(in: viewSize * scale,
                   placement: .fit)
    }
    
    struct Display {
        var id: UUID
        let resolution: CGSize
    }
    var display: Display?
    
    var renderInView: [Int: (Graphic) async -> Bool] = [:]
    
    public init() {}
    
    public func display(graphic3D: Graphic3D) async throws {
        
        await MainActor.run {
            sourceGraphic = graphic3D
        }
        
        try await render()
    }
    
    enum RenderError: String, Error {
        case renderFailed
    }
    
    private func render() async throws {

        guard let sourceGraphic: Graphic3D else { return }
        guard let viewResolution: CGSize else { return }
        
        if let display: Display {
            if display.id == sourceGraphic.id,
               display.resolution == viewResolution {
                return
            }
        }
        
        var viewGraphics: [Graphic] = try await sourceGraphic.samples()
        
        if CGSize(width: sourceGraphic.width, height: sourceGraphic.height) != viewResolution {
    
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
        
        let display = Display(id: sourceGraphic.id,
                              resolution: viewGraphics.first!.resolution)
        await MainActor.run {
            self.display = display
        }
        
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
        sourceGraphic = nil
        display = nil
    }
}

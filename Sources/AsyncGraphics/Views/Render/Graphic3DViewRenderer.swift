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
        return CGSize(width: sourceGraphic.width, height: sourceGraphic.height)
            .place(in: viewSize * .pixelsPerPoint,
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
        print("------> Display")
        
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
            for (index, viewGraphic) in viewGraphics.enumerated() {
                var viewGraphic: Graphic = viewGraphic
                switch interpolation {
                case .linear, .nearestNeighbor:
                    var options: Graphic.EffectOptions = []
                    if interpolation == .nearestNeighbor {
                        options.insert(.interpolateNearest)
                    }
                    viewGraphic = try await viewGraphic
                        .resized(to: viewResolution,
                                 placement: .stretch,
                                 options: options)
                case .lanczos, .bilinear:
                    let method: Graphic.ResizeMethod = interpolation == .lanczos ? .lanczos : .bilinear
                    viewGraphic = try await viewGraphic
                        .resized(to: viewResolution,
                                 placement: .stretch,
                                 method: method)
                }
                viewGraphics[index] = viewGraphic
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

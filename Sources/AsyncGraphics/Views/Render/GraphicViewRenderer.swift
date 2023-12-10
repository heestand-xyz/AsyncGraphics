import Foundation
import Observation
import CoreGraphicsExtensions

@Observable
public final class GraphicViewRenderer {
    
    public var interpolation: ViewInterpolation = .lanczos {
        didSet {
            Task {
                try? await render()
            }
        }
    }
    public let extendedDynamicRange: Bool = false
    
    var sourceGraphic: Graphic?
    
    var viewSize: CGSize? {
        didSet {
            Task {
                try? await render()
            }
        }
    }
    
    var viewResolution: CGSize? {
        guard let viewSize: CGSize else { return nil }
        guard let sourceGraphic: Graphic else { return nil }
        return sourceGraphic.resolution
            .place(in: viewSize * .pixelsPerPoint,
                   placement: .fit)
    }
    
    struct Display {
        var id: UUID
        var graphic: Graphic
        var resolution: CGSize {
            graphic.resolution
        }
    }
    var display: Display?
    
    public init() {}
    
    public func display(graphic: Graphic) async throws {
        
        sourceGraphic = graphic
        
        try await render()
    }
    
    private func render() async throws {
        
        guard let sourceGraphic: Graphic else { return }
        guard let viewResolution: CGSize else { return }
        
        if let display: Display {
            if display.id == sourceGraphic.id,
               display.resolution == viewResolution {
                return
            }
        }
        
        var viewGraphic: Graphic = sourceGraphic
        
        if viewGraphic.colorSpace != .sRGB {
            viewGraphic = try await viewGraphic
                .applyColorSpace(.sRGB)
        }
        
        if sourceGraphic.resolution != viewResolution {
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
        }
        
        let display = Display(id: sourceGraphic.id, graphic: viewGraphic)
        await MainActor.run {
            self.display = display
        }
    }
    
    public func hide() {
        sourceGraphic = nil
        display = nil
    }
}

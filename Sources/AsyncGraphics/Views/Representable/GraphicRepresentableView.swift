//
//  Created by Anton Heestand on 2022-04-24.
//

import SwiftUI
import CoreGraphics
import TextureMap

struct GraphicRepresentableView {
    
    let graphic: Graphic
    let viewResolution: CGSize
    let interpolation: Graphic.ViewInterpolation
    let extendedDynamicRange: Bool
    var preProcessed: Bool = false
    let didRender: (UUID) -> ()
    
    private func render(in view: GraphicMetalViewable) async throws {
        var graphic: Graphic = graphic
        if !preProcessed {
            if extendedDynamicRange {
                let extendedLinearDisplayP3: TMColorSpace = .custom(
                    CGColorSpace(name: CGColorSpace.extendedLinearDisplayP3)!
                )
                if graphic.colorSpace != extendedLinearDisplayP3 {
                    switch graphic.colorSpace {
                    case .nonLinearSRGB:
                        let extendedSRGB: TMColorSpace = .custom(
                            CGColorSpace(name: CGColorSpace.extendedSRGB)!
                        )
                        graphic = graphic
                            .assignColorSpace(extendedSRGB)
                        graphic = try await graphic
                            .applyColorSpace(extendedLinearDisplayP3)
                    case .linearSRGB:
                        let extendedLinearSRGB: TMColorSpace = .custom(
                            CGColorSpace(name: CGColorSpace.extendedLinearSRGB)!
                        )
                        graphic = graphic
                            .assignColorSpace(extendedLinearSRGB)
                        graphic = try await graphic
                            .applyColorSpace(extendedLinearDisplayP3)
                    case .linearDisplayP3:
                        graphic = graphic
                            .assignColorSpace(extendedLinearDisplayP3)
                    default:
                        graphic = try await graphic
                            .applyColorSpace(extendedLinearDisplayP3)
                    }
                }
            } else {
                if graphic.colorSpace != .sRGB {
                    graphic = try await graphic
                        .applyColorSpace(.sRGB)
                }
            }
            if [.nearestNeighbor, .linear].contains(interpolation) {
                var options: Graphic.EffectOptions = []
                if interpolation == .nearestNeighbor {
                    options.insert(.interpolateNearest)
                }
                graphic = try await graphic
                    .resized(to: viewResolution,
                             placement: .stretch,
                             options: options)
            }
        }
        #if os(visionOS)
//        await (view as! GraphicMetalVisionView).renderNeedsDisplay(graphic: graphic)
        await (view as! GraphicMetalVisionView).render(graphic: graphic)
        #else
        await (view as! GraphicMetalView).render(graphic: graphic)
        #endif
    }
}
  
#if os(macOS)

extension GraphicRepresentableView: NSViewRepresentable {
    
    func makeNSView(context: Context) -> GraphicMetalView {
        GraphicMetalView(interpolation: interpolation,
                         extendedDynamicRange: extendedDynamicRange,
                         didRender: didRender)
    }
    
    func updateNSView(_ view: GraphicMetalView, context: Context) {
        if view.extendedDynamicRange != extendedDynamicRange {
            view.set(extendedDynamicRange: extendedDynamicRange)
        }
        Task {
            do {
                try await render(in: view)
            } catch {
                print("AsyncGraphics - View Render Failed:", error)
            }
        }
    }
}

#elseif os(visionOS)

extension GraphicRepresentableView: UIViewRepresentable {
    
    func makeUIView(context: Context) -> GraphicMetalVisionView {
        GraphicMetalVisionView(interpolation: interpolation,
                               extendedDynamicRange: extendedDynamicRange,
                               autoDraw: true,
                               didRender: didRender)
    }
    
    func updateUIView(_ view: GraphicMetalVisionView, context: Context) {
        if view.extendedDynamicRange != extendedDynamicRange {
            view.set(extendedDynamicRange: extendedDynamicRange)
        }
        Task {
            do {
                try await render(in: view)
            } catch {
                print("AsyncGraphics - View Render Failed:", error)
            }
        }
    }
}

#else

extension GraphicRepresentableView: UIViewRepresentable {
    
    func makeUIView(context: Context) -> GraphicMetalView {
        GraphicMetalView(interpolation: interpolation,
                         extendedDynamicRange: extendedDynamicRange,
                         didRender: didRender)
    }
    
    func updateUIView(_ view: GraphicMetalView, context: Context) {
        if view.extendedDynamicRange != extendedDynamicRange {
            view.set(extendedDynamicRange: extendedDynamicRange)
        }
        Task {
            do {
                try await render(in: view)
            } catch {
                print("AsyncGraphics - View Render Failed:", error)
            }
        }
    }
}

#endif

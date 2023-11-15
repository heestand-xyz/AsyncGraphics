//
//  Created by Anton Heestand on 2022-04-24.
//

import SwiftUI

struct GraphicRepresentableView {
    
    let graphic: Graphic
    let viewResolution: CGSize
    let interpolation: GraphicView.Interpolation
    let extendedDynamicRange: Bool
    let didRender: (UUID) -> ()
    
    private func render(in view: GraphicRenderView) {
        Task {
            var graphic: Graphic = graphic
            do {
                if graphic.colorSpace != .sRGB {
                    graphic = try await graphic
                        .applyColorSpace(.sRGB)
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
                view.render(graphic: graphic)
            } catch {
                print("AsyncGraphics - View Render Failed:", error)
            }
        }
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
        render(in: view)
    }
}

#elseif os(iOS)

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
        render(in: view)
    }
}

#elseif os(visionOS)

extension GraphicRepresentableView: UIViewRepresentable {
    
    func makeUIView(context: Context) -> GraphicMetalVisionView {
        GraphicMetalVisionView(interpolation: interpolation,
                               extendedDynamicRange: extendedDynamicRange,
                               didRender: didRender)
    }
    
    func updateUIView(_ view: GraphicMetalVisionView, context: Context) {
        if view.extendedDynamicRange != extendedDynamicRange {
            view.set(extendedDynamicRange: extendedDynamicRange)
        }
        render(in: view)
    }
}

#endif

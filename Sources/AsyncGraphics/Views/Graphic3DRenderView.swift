//
//  Created by Anton Heestand on 2022-12-10.
//

import SwiftUI
import CoreGraphicsExtensions

/// SwiftUI view for rendering and displaying ``Graphic3D``s.
public struct Graphic3DRenderView: View {
    
    @Bindable private var renderer: Graphic3DViewRenderer
    
    public init(renderer: Graphic3DViewRenderer) {
        _renderer = Bindable(renderer)
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.clear
                if let sourceGraphic: Graphic3D = renderer.sourceGraphic,
                   let graphics: [Graphic] = renderer.display?.graphics,
                   let viewResolution: CGSize = renderer.viewResolution {
                    ForEach(Array(graphics.enumerated()), id: \.element.id) { index, graphic in
                        GeometryReader { contentGeometry in
                            GraphicRepresentableView(graphic: graphic,
                                                     viewResolution: viewResolution,
                                                     interpolation: renderer.interpolation,
                                                     extendedDynamicRange: renderer.extendedDynamicRange,
                                                     preProcessed: true) { _ in }
#if os(visionOS)
                                .offset(z: {
                                    let count: Int = max(2, Int(sourceGraphic.depth))
                                    let fraction: CGFloat = CGFloat(index) / CGFloat(count - 1)
                                    let depthAspectRatio: CGFloat = sourceGraphic.depth / sourceGraphic.height
                                    return fraction * contentGeometry.size.height * depthAspectRatio
                                }())
#endif
                        }
                        .aspectRatio(graphic.resolution,
                                     contentMode: .fit)
                    }
                }
            }
            .onAppear {
                renderer.viewSize = geometry.size
            }
            .onChange(of: geometry.size) { _, newSize in
                renderer.viewSize = newSize
            }
        }
    }
}

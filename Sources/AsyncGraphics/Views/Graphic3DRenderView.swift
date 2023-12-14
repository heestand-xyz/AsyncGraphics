//
//  Created by Anton Heestand on 2022-12-10.
//

#if os(visionOS)

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
                if let sourceGraphic: Graphic3D = renderer.sourceGraphic {
                    ForEach(Array(0..<Int(sourceGraphic.depth)), id: \.self) { index in
                        GeometryReader { contentGeometry in
                            GraphicVisionRepresentableView(
                                interpolation: renderer.interpolation,
                                extendedDynamicRange: renderer.extendedDynamicRange
                            ) { renderInView in
                                renderer.renderInView[index] = renderInView
                            }
                            .offset(z: {
                                let count: Int = max(2, Int(sourceGraphic.depth))
                                let fraction: CGFloat = CGFloat(index) / CGFloat(count - 1)
                                let depthAspectRatio: CGFloat = sourceGraphic.depth / sourceGraphic.height
                                return fraction * contentGeometry.size.height * depthAspectRatio
                            }())
                        }
                        .aspectRatio(CGSize(width: sourceGraphic.width,
                                            height: sourceGraphic.height),
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

#endif

//
//  Created by Anton Heestand on 2022-12-10.
//

import SwiftUI
import CoreGraphicsExtensions

/// SwiftUI view for rendering and displaying ``Graphic``s.
public struct GraphicRenderView: View {
    
    @Bindable private var renderer: GraphicViewRenderer
    
    public init(renderer: GraphicViewRenderer) {
        self.renderer = renderer
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.clear
                if let graphic: Graphic = renderer.display?.graphic,
                   let viewResolution: CGSize = renderer.viewResolution {
                    GraphicRepresentableView(graphic: graphic,
                                             viewResolution: viewResolution,
                                             interpolation: renderer.interpolation,
                                             extendedDynamicRange: false,
                                             preProcessed: true) { _ in }
                        .aspectRatio(graphic.resolution,
                                     contentMode: .fit)
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

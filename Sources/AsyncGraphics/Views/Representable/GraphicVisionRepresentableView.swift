//
//  Created by Anton Heestand on 2022-04-24.
//

#if os(visionOS)

import SwiftUI

struct GraphicVisionRepresentableView: UIViewRepresentable {
    
    let interpolation: ViewInterpolation
    let extendedDynamicRange: Bool
    let renderInView: (@escaping (Graphic) async -> Bool) -> ()
    
    func makeUIView(context: Context) -> GraphicMetalVisionView {
        let view = GraphicMetalVisionView(interpolation: interpolation,
                                          extendedDynamicRange: extendedDynamicRange,
                                          autoDraw: false,
                                          didRender: { _ in })
        renderInView({ graphic in
            await view.render(graphic: graphic)
        })
        return view
    }
    
    func updateUIView(_ view: GraphicMetalVisionView, context: Context) {
        if view.extendedDynamicRange != extendedDynamicRange {
            view.set(extendedDynamicRange: extendedDynamicRange)
        }
    }
}

#endif

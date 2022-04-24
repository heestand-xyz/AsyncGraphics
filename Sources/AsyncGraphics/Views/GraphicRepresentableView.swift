//
//  Created by Anton Heestand on 2022-04-24.
//

import SwiftUI

#if os(macOS)

struct GraphicRepresentableView: NSViewRepresentable {
    
    private let graphic: Graphic
    
    init(graphic: Graphic) {
        self.graphic = graphic
    }
    
    func makeNSView(context: Context) -> GraphicMetalView {
        GraphicMetalView()
    }
    
    func updateNSView(_ view: GraphicMetalView, context: Context) {
        view.render(graphic: graphic)
    }
}

#else

struct GraphicRepresentableView: UIViewRepresentable {
    
    private let graphic: Graphic
    
    init(graphic: Graphic) {
        self.graphic = graphic
    }
    
    func makeUIView(context: Context) -> GraphicMetalView {
        GraphicMetalView()
    }
    
    func updateUIView(_ view: GraphicMetalView, context: Context) {
        view.render(graphic: graphic)
    }
}

#endif

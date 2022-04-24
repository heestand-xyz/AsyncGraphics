//
//  Created by Anton Heestand on 2022-04-24.
//

import SwiftUI

#if os(macOS)

public struct GraphicRepresentableView: NSViewRepresentable {
    
    private let graphic: Graphic
    
    public init(graphic: Graphic) {
        self.graphic = graphic
    }
    
    public func makeNSView(context: Context) -> GraphicMetalView {
        GraphicMetalView()
    }
    
    public func updateNSView(_ view: GraphicMetalView, context: Context) {
        view.render(graphic: graphic)
    }
}

#else

public struct GraphicRepresentableView: UIViewRepresentable {
    
    private let graphic: Graphic
    
    public init(graphic: Graphic) {
        self.graphic = graphic
    }
    
    public func makeUIView(context: Context) -> GraphicMetalView {
        GraphicMetalView()
    }
    
    public func updateUIView(_ view: GraphicMetalView, context: Context) {
        view.render(graphic: graphic)
    }
}

#endif

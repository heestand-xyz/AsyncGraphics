//
//  Created by Anton Heestand on 2022-04-24.
//

import SwiftUI

/// SwiftUI view for displaying graphics.
public struct GraphicView: View {
    
    private let graphic: Graphic
    
    public init(graphic: Graphic) {
        self.graphic = graphic
    }
    
    public var body: some View {
        GraphicRepresentableView(graphic: graphic)
            .aspectRatio(graphic.resolution, contentMode: .fit)
    }
}

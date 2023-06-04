//
//  Created by Anton Heestand on 2022-04-24.
//

import SwiftUI
import CoreGraphicsExtensions

/// SwiftUI view for displaying a ``Graphic``.
public struct GraphicView: View {
    
    private let graphic: Graphic
    
    public enum Interpolation {
        case nearestNeighbor
        case linear
        case lanczos
        case bilinear
    }
    private let interpolation: Interpolation
    
    public init(graphic: Graphic, interpolation: Interpolation = .lanczos) {
        self.graphic = graphic
        self.interpolation = interpolation
    }
    
    public var body: some View {
        GeometryReader { geometry in
            GraphicRepresentableView(graphic: graphic,
                                     viewResolution: geometry.size * .pixelsPerPoint,
                                     interpolation: interpolation)
        }
            .aspectRatio(graphic.resolution, contentMode: .fit)
    }
}

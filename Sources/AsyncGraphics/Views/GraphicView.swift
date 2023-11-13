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
    
    private let extendedDynamicRange: Bool
    
    /// Graphic View
    /// - Parameters:
    ///   - graphic: The graphic to display.
    ///   - interpolation: The pixel interpolation mode.
    ///   - extendedDynamicRange: XDR high brightness support (16 or 32 bit).
    public init(graphic: Graphic,
                interpolation: Interpolation = .lanczos,
                extendedDynamicRange: Bool = false) {
        self.graphic = graphic
        self.interpolation = interpolation
        self.extendedDynamicRange = extendedDynamicRange
    }
    
    public var body: some View {
        GeometryReader { geometry in
            GraphicRepresentableView(graphic: graphic,
                                     viewResolution: geometry.size * .pixelsPerPoint,
                                     interpolation: interpolation,
                                     extendedDynamicRange: extendedDynamicRange)
        }
        .aspectRatio(graphic.resolution, contentMode: .fit)
    }
}

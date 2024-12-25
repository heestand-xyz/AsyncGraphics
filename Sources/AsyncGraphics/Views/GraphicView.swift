//
//  Created by Anton Heestand on 2022-04-24.
//

import SwiftUI
import CoreGraphicsExtensions

/// SwiftUI view for displaying a ``Graphic``.
public struct GraphicView: View {
    
    private let graphic: Graphic
    
    private let renderUpdate: ((GraphicRenderState) -> ())?

    private let interpolation: Graphic.ViewInterpolation
    
    private let extendedDynamicRange: Bool
    
    /// Graphic View
    /// - Parameters:
    ///   - graphic: The graphic to display.
    ///   - interpolation: The pixel interpolation mode.
    ///   - extendedDynamicRange: XDR high brightness support (16 or 32 bit).
    public init(graphic: Graphic,
                interpolation: Graphic.ViewInterpolation = .lanczos,
                extendedDynamicRange: Bool = false,
                renderUpdate: ((GraphicRenderState) -> ())? = nil) {
        self.graphic = graphic
        self.interpolation = interpolation
        self.extendedDynamicRange = extendedDynamicRange
        self.renderUpdate = renderUpdate
    }
    
    public var body: some View {
        GeometryReader { geometry in
            GraphicRepresentableView(graphic: graphic,
                                     viewResolution: geometry.size * .pixelsPerPoint,
                                     interpolation: interpolation,
                                     extendedDynamicRange: extendedDynamicRange) { id in
                renderUpdate?(.done(id: id))
            }
        }
        .aspectRatio(graphic.resolution, contentMode: .fit)
        .onChange(of: graphic) { _, newGraphic in
            renderUpdate?(.inProgress(id: newGraphic.id))
        }
    }
}

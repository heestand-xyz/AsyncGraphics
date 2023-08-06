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
    
    #if os(xrOS)
    @State private var image: UIImage?
    #endif
    
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
            #if os(xrOS)
            if let image {
                Image(uiImage: image)
                    .resizable()
            }
            #else
            GraphicRepresentableView(graphic: graphic,
                                     viewResolution: geometry.size * .pixelsPerPoint,
                                     interpolation: interpolation,
                                     extendedDynamicRange: extendedDynamicRange)
            #endif
        }
        .aspectRatio(graphic.resolution, contentMode: .fit)
        #if os(xrOS)
        .task {
            do {
                image = try await graphic.image
            } catch {
                print("AsyncGraphics View Render Failed:", error)
            }
        }
        .onChange(of: graphic) { _, newGraphic in
            Task {
                do {
                    image = try await newGraphic.image
                } catch {
                    print("AsyncGraphics View Render Failed:", error)
                }
            }
        }
        #endif
    }
}

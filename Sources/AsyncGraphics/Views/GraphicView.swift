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
    
    #if os(xrOS)
    @State private var image: UIImage?
    #endif
    
    public init(graphic: Graphic, interpolation: Interpolation = .lanczos) {
        self.graphic = graphic
        self.interpolation = interpolation
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
                                     interpolation: interpolation)
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

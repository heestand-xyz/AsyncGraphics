//
//  Created by Anton Heestand on 2022-04-24.
//

import SwiftUI
import CoreGraphicsExtensions

/// SwiftUI view for displaying a ``Graphic3D``.
public struct Graphic3DView: View {
    
    private let graphic3D: Graphic3D
    @State private var graphics: [Graphic] = []
    
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
    ///   - graphic3D: The 3D graphic to display.
    ///   - interpolation: The pixel interpolation mode.
    ///   - extendedDynamicRange: XDR high brightness support (16 or 32 bit).
    public init(graphic3D: Graphic3D,
                interpolation: Interpolation = .lanczos,
                extendedDynamicRange: Bool = false) {
        self.graphic3D = graphic3D
        self.interpolation = interpolation
        self.extendedDynamicRange = extendedDynamicRange
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(Array(graphics.enumerated()), id: \.element.id) { index, graphic in
                    GraphicView(graphic: graphic)
                        .offset(z: CGFloat(index) * (geometry.size.height / CGFloat(graphic3D.height)))
                }
            }
        }
        .aspectRatio(CGSize(width: graphic3D.width, height: graphic3D.height), contentMode: .fit)
        .task {
            do {
                graphics = try await graphic3D.samples()
            } catch {
                print("AsyncGraphics - Graphic3DView - Failed to get samples:", error)
            }
        }
        .onChange(of: graphic3D) { graphic3D in
            Task {
                do {
                    graphics = try await graphic3D.samples()
                } catch {
                    print("AsyncGraphics - Graphic3DView - Failed to get new samples:", error)
                }
            }
        }
    }
}

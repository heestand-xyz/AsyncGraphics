//
//  Created by Anton Heestand on 2022-04-24.
//

import SwiftUI
import CoreGraphics
import CoreGraphicsExtensions

/// SwiftUI view for displaying a ``Graphic3D``.
public struct Graphic3DView: View {
    
    private let graphic3D: Graphic3D
    @State private var graphics: [Graphic] = []
    
    private let renderUpdate: ((Graphic3DRenderState) -> ())?
    @State private var renderStates: [Int: GraphicRenderState] = [:]
    
    private let interpolation: GraphicView.Interpolation
    
    private let extendedDynamicRange: Bool
    
    /// Graphic View
    /// - Parameters:
    ///   - graphic3D: The 3D graphic to display.
    ///   - interpolation: The pixel interpolation mode.
    ///   - extendedDynamicRange: XDR high brightness support (16 or 32 bit).
    public init(graphic3D: Graphic3D,
                interpolation: GraphicView.Interpolation = .lanczos,
                extendedDynamicRange: Bool = false,
                renderUpdate: ((Graphic3DRenderState) -> ())? = nil) {
        self.graphic3D = graphic3D
        self.interpolation = interpolation
        self.extendedDynamicRange = extendedDynamicRange
        self.renderUpdate = renderUpdate
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(Array(graphics.enumerated()), id: \.element.id) { index, graphic in
                    GraphicView(graphic: graphic,
                                interpolation: interpolation,
                                extendedDynamicRange: extendedDynamicRange) { renderState in
                        renderStates[index] = renderState
                        checkRenderStates()
                    }
#if os(visionOS)
                        .offset(z: {
                            let count: Int = graphics.count > 0 ? graphics.count : 1
                            let depthAspectRatio: CGFloat = CGFloat(graphic3D.depth) / CGFloat(graphic3D.height)
                            let fraction: CGFloat = CGFloat(index) / CGFloat(count)
                            return fraction * geometry.size.height * depthAspectRatio
                        }())
#endif
                }
            }
        }
        .aspectRatio(CGSize(width: graphic3D.width, height: graphic3D.height), contentMode: .fit)
        .task {
            do {
                try await sample(graphic3D: graphic3D)
            } catch {
                print("AsyncGraphics - Graphic3DView - Failed to get samples:", error)
            }
        }
        .onChange(of: graphic3D) { graphic3D in
            Task {
                do {
                    try await sample(graphic3D: graphic3D)
                } catch {
                    print("AsyncGraphics - Graphic3DView - Failed to get new samples:", error)
                }
            }
        }
    }
    
    private func sample(graphic3D: Graphic3D) async throws {
        renderStates = [:]
        renderUpdate?(.inProgress(id: graphic3D.id, fractionComplete: 0.0))
        graphics = try await graphic3D.samples()
    }
    
    private func checkRenderStates() {
        guard renderStates.count == graphic3D.depth else { return }
        let doneCount: Int = renderStates.filter({ index, renderState in
            guard case .done(let id) = renderState else { return false }
            return true
        }).count
        if doneCount == graphic3D.depth {
            renderUpdate?(.done(id: graphic3D.id))
        } else {
            let fraction = CGFloat(doneCount) / CGFloat(graphic3D.depth)
            renderUpdate?(.inProgress(id: graphic3D.id, fractionComplete: fraction))
        }
    }
}

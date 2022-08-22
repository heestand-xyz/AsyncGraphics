//
//  Created by Anton Heestand on 2022-04-24.
//

import SwiftUI
import VoxelView

/// SwiftUI view for displaying 3D graphics.
public struct Graphic3DView: View {
    
    private let graphic3D: Graphic3D
    @State private var transform: Transform
    
    @State private var startZoom: CGFloat?
    @State private var startRotationX: Angle?
    @State private var startRotationY: Angle?

    public init(graphic3D: Graphic3D,
                transform: Transform = .identity) {
        self.graphic3D = graphic3D
        _transform = State(wrappedValue: transform)
    }
    
    public var body: some View {
        VoxelView(texture: graphic3D.texture,
                  textureID: graphic3D.id,
                  zoom: transform.zoom,
                  rotationX: transform.rotationX,
                  rotationY: transform.rotationY)
        .gesture(
            DragGesture()
                .onChanged { value in
                    if startRotationX == nil {
                        startRotationX = transform.rotationX
                        startRotationY = transform.rotationY
                    }
                    transform.rotationX = min(max(.degrees(-value.translation.height) + startRotationX!, .degrees(-90)), .degrees(90))
                    transform.rotationY = .degrees(-value.translation.width) + startRotationY!
                }
                .onEnded { _ in
                    startRotationX = nil
                    startRotationY = nil
                }
        )
        .gesture(
            MagnificationGesture()
                .onChanged { scale in
                    if startZoom == nil {
                        startZoom = transform.zoom
                    }
                    transform.zoom = scale * startZoom!
                }
                .onEnded { _ in
                    startZoom = nil
                }
        )
    }
}

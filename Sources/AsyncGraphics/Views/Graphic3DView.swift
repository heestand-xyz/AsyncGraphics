//
//  Created by Anton Heestand on 2022-04-24.
//

import SwiftUI
import VoxelView

/// SwiftUI view for displaying 3D graphics.
public struct Graphic3DView: View {
    
    private let graphic3D: Graphic3D
    private let scale: CGFloat
    private let rotationX: Angle
    private let rotationY: Angle
    
    public init(graphic3D: Graphic3D,
                scale: CGFloat = 1.0,
                rotationX: Angle = .zero,
                rotationY: Angle = .zero) {
        self.graphic3D = graphic3D
        self.scale = scale
        self.rotationX = rotationX
        self.rotationY = rotationY
    }
    
    public var body: some View {
        VoxelView(texture: graphic3D.texture,
                  textureID: graphic3D.id,
                  scale: scale,
                  rotationX: rotationX,
                  rotationY: rotationY)
    }
}

//
//  Created by Anton Heestand on 2022-04-24.
//

import SwiftUI
import VoxelView

/// SwiftUI view for displaying 3D graphics.
public struct Graphic3DView: View {
    
    private let graphic3D: Graphic3D
    
    public init(graphic3D: Graphic3D) {
        self.graphic3D = graphic3D
    }
    
    public var body: some View {
        VoxelView(texture: graphic3D.texture)
    }
}

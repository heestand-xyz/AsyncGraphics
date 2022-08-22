//
//  Created by Anton Heestand on 2022-08-22.
//

import SwiftUI

extension Graphic3DView {
 
    public struct Transform {
        
        public var zoom: CGFloat
        
        public var rotationX: Angle
        public var rotationY: Angle
        
        public static let identity = Transform(zoom: 1.0, rotationX: .zero, rotationY: .zero)
    }
}

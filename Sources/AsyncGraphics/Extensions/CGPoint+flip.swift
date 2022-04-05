//
//  Created by Anton Heestand on 2022-04-05.
//

import CoreGraphics

extension CGPoint {
    
    func flipY(size: CGSize) -> CGPoint {
        CGPoint(x: x, y: size.height - y)
    }
}

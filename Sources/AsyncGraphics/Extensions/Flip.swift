//
//  Created by Anton Heestand on 2022-04-05.
//

import CoreGraphics

extension CGPoint {
    
    func flipPositionY(size: CGSize) -> CGPoint {
        CGPoint(x: x, y: size.height - y)
    }
    
    func flipTranslationY(size: CGSize) -> CGPoint {
        CGPoint(x: x, y: -y)
    }
}

extension CGRect {
    
    func flipY(size: CGSize) -> CGRect {
        CGRect(x: minX, y: size.height - maxY, width: width, height: height)
    }
}

//
//  Created by Anton Heestand on 2022-04-05.
//

import CoreGraphics

extension CGPoint {
    
    @available(*, deprecated)
    func flipPositionY(size: CGSize) -> CGPoint {
        CGPoint(x: x, y: size.height - y)
    }
    
    @available(*, deprecated)
    func flipTranslationY(size: CGSize) -> CGPoint {
        CGPoint(x: x, y: -y)
    }
}

extension CGRect {
    
    @available(*, deprecated)
    func flipY(size: CGSize) -> CGRect {
        CGRect(x: minX, y: size.height - maxY, width: width, height: height)
    }
}

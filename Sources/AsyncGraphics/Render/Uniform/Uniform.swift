//
//  Created by Anton Heestand on 2022-04-03.
//

import CoreGraphics
import PixelColor

protocol Uniform {
    var floats: [CGFloat]? { get }
}

extension Uniform {
    
    var rawUniforms: [RawUniform] {
        if let bool: Bool = self as? Bool {
            return [bool]
        } else if let int: Int = self as? Int {
            return [int]
        } else {
            return floats?.map(Float.init) ?? []
        }
    }
}

// MARK: - Implementations

extension Bool: Uniform {
    var floats: [CGFloat]? { nil }
}

extension Int: Uniform {
    var floats: [CGFloat]? { nil }
}

extension CGFloat: Uniform {
    var floats: [CGFloat]? { [self] }
}

extension CGPoint: Uniform {
    var floats: [CGFloat]? { [x, y] }
}

extension CGSize: Uniform {
    var floats: [CGFloat]? { [width, height] }
}

extension PixelColor: Uniform {
    var floats: [CGFloat]? { [red, green, blue, alpha] }
}

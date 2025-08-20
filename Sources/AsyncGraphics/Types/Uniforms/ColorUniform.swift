//
//  Created by Anton Heestand on 2022-04-05.
//

import PixelColor

struct ColorUniform: Uniforms {
    
    let red: Float
    let green: Float
    let blue: Float
    let alpha: Float
}

extension PixelColor {
    
    var uniform: ColorUniform {
        ColorUniform(red: Float(red),
                     green: Float(green),
                     blue: Float(blue),
                     alpha: Float(opacity))
    }
}

extension ColorUniform {
    static let clear = ColorUniform(red: 0.0, 
                                    green: 0.0,
                                    blue: 0.0,
                                    alpha: 0.0)
}

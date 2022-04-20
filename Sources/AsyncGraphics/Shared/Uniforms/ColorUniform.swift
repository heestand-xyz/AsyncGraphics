//
//  Created by Anton Heestand on 2022-04-05.
//

import PixelColor

struct ColorUniform {
    
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
                     alpha: Float(alpha))
    }
}

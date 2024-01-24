//
//  Created by Anton Heestand on 2022-04-03.
//

import CoreGraphics
import CoreGraphicsExtensions

extension Graphic {
    
    @EnumMacro
    public enum Placement: String, GraphicEnum {
        case stretch
        case fit
        case fill
        case fixed
    }
}

extension Graphic.Placement {
    
    var sizePlacement: CGSize.Placement {
        switch self {
        case .stretch: .stretch
        case .fit: .fit
        case .fill: .fill
        case .fixed: .fixed
        }
    }
}

//
//  Created by Anton Heestand on 2022-04-03.
//

extension Graphic {
    
    @EnumMacro
    public enum Placement: String, GraphicEnum {
        case stretch
        case fit
        case fill
        case fixed
    }
}

//
//  Created by Heestand, Anton Norman | Anton | GSSD on 2023/02/06.
//

import CoreGraphics

public protocol G: Hashable {
    func render(at resolution: CGSize) async throws -> Graphic
}

extension G {
    
    func isEqual(to g: any G) -> Bool {
        guard let g = g as? Self else { return false }
        return self == g
    }
}

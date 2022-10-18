//
//  Created by Anton Heestand on 2022-10-08.
//

import CoreGraphics

extension CGSize {
    
    public func place(in size: CGSize, placement: Placement) -> CGSize {
       
        switch placement {
        case .fit:
            return CGSize(width: width / size.width > height / size.height ? size.width : width * (size.height / height),
                          height: width / size.width < height / size.height ? size.height : height * (size.width / width))
        case .fill:
            return CGSize(width: width / size.width < height / size.height ? size.width : width * (size.height / height),
                          height: width / size.width > height / size.height ? size.height : height * (size.width / width))
        case .center:
            return self
        case .stretch:
            return size
        }
    }
}

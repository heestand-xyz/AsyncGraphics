import CoreGraphics

public struct AGDynamicResolution: Hashable {
    
    var width: CGFloat?
    var height: CGFloat?
    
    static let auto = AGDynamicResolution(width: nil, height: nil)
    
    var size: CGSize? {
        guard let width, let height else { return nil }
        return CGSize(width: width, height: height)
    }
    
    static func fixed(width: CGFloat,
                      height: CGFloat) -> AGDynamicResolution {
        AGDynamicResolution(width: width, height: height)
    }
    
    static func fixed(_ size: CGSize) -> AGDynamicResolution {
        AGDynamicResolution(width: size.width, height: size.height)
    }
    
    static func semiAuto(fixedWidth: CGFloat? = nil,
                         fixedHeight: CGFloat? = nil) -> AGDynamicResolution {
        AGDynamicResolution(width: fixedWidth, height: fixedHeight)
    }
}

extension AGDynamicResolution {
    
    func fallback(to resolution: CGSize) -> CGSize {
        CGSize(width: width ?? resolution.width,
               height: height ?? resolution.height)
    }
}
//
//extension AGDynamicResolution {
//    
//    mutating func add(width: CGFloat?) {
//        if let width {
//            if let currentWidth = self.width {
//                self.width = currentWidth + width
//            } else {
//                self.width = width
//            }
//        }
//    }
//    
//    mutating func add(height: CGFloat?) {
//        if let height {
//            if let currentHeight = self.height {
//                self.height = currentHeight + height
//            } else {
//                self.height = height
//            }
//        }
//    }
//}
//
//extension AGDynamicResolution {
//    
//    mutating func max(width: CGFloat?) {
//        if let width {
//            if let currentWidth = self.width {
//                self.width = Swift.max(currentWidth, width)
//            } else {
//                self.width = width
//            }
//        }
//    }
//    
//    mutating func max(height: CGFloat?) {
//        if let height {
//            if let currentHeight = self.height {
//                self.height = Swift.max(currentHeight, height)
//            } else {
//                self.height = height
//            }
//        }
//    }
//}

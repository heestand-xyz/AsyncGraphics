import CoreGraphics

public struct AGResolution: Hashable {
    
    let width: CGFloat?
    let height: CGFloat?
    
    static let auto = AGResolution(width: nil, height: nil)
    
    var size: CGSize? {
        guard let width, let height else { return nil }
        return CGSize(width: width, height: height)
    }
    
    init(width: CGFloat?, height: CGFloat?) {
        self.width = width
        self.height = height
    }
    init(_ size: CGSize) {
        width = size.width
        height = size.height
    }
}

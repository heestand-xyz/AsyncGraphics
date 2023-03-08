import Foundation

extension Graphic {
    
    public struct EdgeInsets: OptionSet {
        
        public let rawValue: Int
        
        public static let top = EdgeInsets(rawValue: 1 << 0)
        public static let bottom = EdgeInsets(rawValue: 1 << 1)
        public static let leading = EdgeInsets(rawValue: 1 << 2)
        public static let trailing = EdgeInsets(rawValue: 1 << 3)
        public static let horizontal = EdgeInsets(rawValue: 1 << 4)
        public static let vertical = EdgeInsets(rawValue: 1 << 5)
        public static let all = EdgeInsets(rawValue: 1 << 6)
        
        var onLeading: Bool {
            [.leading, .horizontal, .all].contains(self)
        }
        
        var onTrailing: Bool {
            [.trailing, .horizontal, .all].contains(self)
        }
        
        var onTop: Bool {
            [.top, .vertical, .all].contains(self)
        }
        
        var onBottom: Bool {
            [.bottom, .vertical, .all].contains(self)
        }
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
}

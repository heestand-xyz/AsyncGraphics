import CoreGraphics
import Spatial

public enum GraphicMetadataValue<T: GraphicValue>: Codable {
    
    case zero
    case one
    
    case fixed(T)
    
    public enum Alignment: Codable {
        case leading
        case center
        case trailing
        case topLeading
        case top
        case topTrailing
        case bottomLeading
        case bottom
        case bottomTrailing
        var xFraction: CGFloat {
            switch self {
            case .center, .top, .bottom:
                return 0.5
            case .leading, .topLeading, .bottomLeading:
                return 0.0
            case .trailing, .topTrailing, .bottomTrailing:
                return 1.0
            }
        }
        var yFraction: CGFloat {
            switch self {
            case .center, .leading, .trailing:
                return 0.5
            case .top, .topLeading, .topTrailing:
                return 0.0
            case .bottom, .bottomLeading, .bottomTrailing:
                return 1.0
            }
        }
    }
    
    case resolution
    case resolutionAlignment(Alignment)
    case resolutionMinimum(fraction: CGFloat)
    case resolutionMaximum(fraction: CGFloat)
    
    public func eval(at resolution: CGSize) -> T {
        switch self {
        case .zero:
            return T.zero
        case .one:
            return T.one
        case .fixed(let value):
            return value
        case .resolution:
            if T.self == CGPoint.self {
                return CGPoint(x: resolution.width,
                               y: resolution.height) as! T
            } else if T.self == CGSize.self {
                return resolution as! T
            } else if T.self == CGRect.self {
                return CGRect(origin: .zero,
                              size: resolution) as! T
            }
            fatalError("Resolution Not Supported")
        case .resolutionAlignment(let alignment):
            if T.self == CGPoint.self {
                return CGPoint(x: resolution.width * alignment.xFraction,
                               y: resolution.height * alignment.yFraction) as! T
            }
            fatalError("Resolution Center Not Supported")
        case .resolutionMinimum(let fraction):
            let minimum: CGFloat = min(resolution.width, resolution.height)
            return .lerp(at: fraction, from: .zero, to: .one.scaled(by: minimum))
        case .resolutionMaximum(let fraction):
            let maximum: CGFloat = max(resolution.width, resolution.height)
            return .lerp(at: fraction, from: .zero, to: .one.scaled(by: maximum))
        }
    }
    
    public func eval(at resolution: Size3D) -> T {
        switch self {
        case .zero:
            return T.zero
        case .one:
            return T.one
        case .fixed(let value):
            return value
        case .resolution:
            if T.self == Size3D.self {
                return resolution as! T
            } else if T.self == Point3D.self {
                return Point3D(resolution) as! T
            }
            fatalError("Resolution Not Supported")
        case .resolutionAlignment(let alignment):
            if T.self == Point3D.self {
                return Point3D(x: resolution.width * alignment.xFraction,
                               y: resolution.height * alignment.yFraction,
                               z: resolution.depth / 2) as! T
            }
            fatalError("Resolution Center Not Supported")
        case .resolutionMinimum(let fraction):
            let minimum: Double = min(min(resolution.width, resolution.height), resolution.depth)
            return .lerp(at: fraction, from: .zero, to: .one.scaled(by: minimum))
        case .resolutionMaximum(let fraction):
            let maximum: Double = max(max(resolution.width, resolution.height), resolution.depth)
            return .lerp(at: fraction, from: .zero, to: .one.scaled(by: maximum))
        }
    }
}

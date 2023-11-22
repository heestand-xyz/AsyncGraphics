import CoreGraphics
import simd

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
                return 0.5
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
    
    func at(resolution: CGSize) -> T {
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
    
    func at(resolution: SIMD3<Int>) -> T {
        switch self {
        case .zero:
            return T.zero
        case .one:
            return T.one
        case .fixed(let value):
            return value
        case .resolution:
            if T.self == SIMD3<Int>.self {
                return resolution as! T
            } else if T.self == SIMD3<Double>.self {
                return SIMD3<Double>(resolution) as! T
            }
            fatalError("Resolution Not Supported")
        case .resolutionAlignment(let alignment):
            if T.self == SIMD3<Double>.self {
                return SIMD3<Double>(Double(resolution.x) * alignment.xFraction,
                                     Double(resolution.y) * alignment.yFraction,
                                     Double(resolution.z) / 2) as! T
            }
            fatalError("Resolution Center Not Supported")
        case .resolutionMinimum(let fraction):
            let minimum = Double(min(min(resolution.x, resolution.y), resolution.z))
            return .lerp(at: fraction, from: .zero, to: .one.scaled(by: minimum))
        case .resolutionMaximum(let fraction):
            let maximum = Double(max(max(resolution.x, resolution.y), resolution.z))
            return .lerp(at: fraction, from: .zero, to: .one.scaled(by: maximum))
        }
    }
}

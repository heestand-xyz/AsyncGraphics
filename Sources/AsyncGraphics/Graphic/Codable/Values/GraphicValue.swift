import SwiftUI
import simd
import CoreGraphics
import PixelColor

public protocol GraphicValue: Codable {
    
    static var zero: Self { get }
    static var one: Self { get }
    static var `default`: GraphicMetadataValue<Self> { get }
    static var minimum: GraphicMetadataValue<Self> { get }
    static var maximum: GraphicMetadataValue<Self> { get }
    
    static func lerp(at fraction: CGFloat, from leading: Self, to trailing: Self) -> Self
    
    func scaled(by scale: CGFloat) -> Self
}

extension Bool: GraphicValue {
    
    public static var zero: Self { false }
    public static var one: Self { true }
    public static var `default`: GraphicMetadataValue<Self> { .fixed(false) }
    public static var minimum: GraphicMetadataValue<Self> { .fixed(false) }
    public static var maximum: GraphicMetadataValue<Self> { .fixed(true) }
    
    public static func lerp(at fraction: CGFloat, from leading: Self, to trailing: Self) -> Self {
        fraction > 0.0 ? trailing : leading
    }
    
    public func scaled(by scale: CGFloat) -> Self {
        self
    }
}

extension Int: GraphicValue {
    
    public static var zero: Self { 0 }
    public static var one: Self { 1 }
    public static var `default`: GraphicMetadataValue<Self> { .fixed(1) }
    public static var minimum: GraphicMetadataValue<Self> { .fixed(1) }
    public static var maximum: GraphicMetadataValue<Self> { .fixed(10) }
    
    public static func lerp(at fraction: CGFloat, from leading: Self, to trailing: Self) -> Self {
        Int(Double(leading) * (1.0 - fraction) + Double(trailing) * fraction)
    }
    
    public func scaled(by scale: CGFloat) -> Self {
        Int(Double(self) * scale)
    }
}

extension Double: GraphicValue {
    
    public static var zero: Self { 0.0 }
    public static var one: Self { 1.0 }
    public static var `default`: GraphicMetadataValue<Self> { .fixed(0.0) }
    public static var minimum: GraphicMetadataValue<Self> { .fixed(0.0) }
    public static var maximum: GraphicMetadataValue<Self> { .fixed(1.0) }
    
    public static func lerp(at fraction: CGFloat, from leading: Self, to trailing: Self) -> Self {
        leading * (1.0 - fraction) + trailing * fraction
    }
    
    public func scaled(by scale: CGFloat) -> Self {
        self * scale
    }
}

extension CGFloat: GraphicValue {
    
    public static var zero: Self { 0.0 }
    public static var one: Self { 1.0 }
    public static var `default`: GraphicMetadataValue<Self> { .fixed(0.0) }
    public static var minimum: GraphicMetadataValue<Self> { .fixed(0.0) }
    public static var maximum: GraphicMetadataValue<Self> { .fixed(1.0) }
    
    public static func lerp(at fraction: CGFloat, from leading: Self, to trailing: Self) -> Self {
        leading * (1.0 - fraction) + trailing * fraction
    }
    
    public func scaled(by scale: CGFloat) -> Self {
        self * scale
    }
}

extension Angle: GraphicValue {
    
    public static var zero: Self { .degrees(0) }
    public static var one: Self { .degrees(360) }
    public static var `default`: GraphicMetadataValue<Self> { .zero }
    public static var minimum: GraphicMetadataValue<Self> { .fixed(.degrees(-180)) }
    public static var maximum: GraphicMetadataValue<Self> { .fixed(.degrees(180)) }
    
    public static func lerp(at fraction: CGFloat, from leading: Self, to trailing: Self) -> Self {
        .degrees(Double.lerp(at: fraction, from: leading.degrees, to: trailing.degrees))
    }
    
    public func scaled(by scale: CGFloat) -> Self {
        .degrees(degrees.scaled(by: scale))
    }
}

extension CGSize: GraphicValue {
    
    public static var zero: Self { CGSize(width: 0.0, height: 0.0) }
    public static var one: Self { CGSize(width: 1.0, height: 1.0) }
    public static var `default`: GraphicMetadataValue<Self> { .resolution }
    public static var minimum: GraphicMetadataValue<Self> { .zero }
    public static var maximum: GraphicMetadataValue<Self> { .resolution }
    
    public static func lerp(at fraction: CGFloat, from leading: Self, to trailing: Self) -> Self {
        CGSize(width: Double.lerp(at: fraction, from: leading.width, to: trailing.width),
               height: Double.lerp(at: fraction, from: leading.height, to: trailing.height))
    }
    
    public func scaled(by scale: CGFloat) -> Self {
        CGSize(width: width.scaled(by: scale),
               height: height.scaled(by: scale))
    }
}

extension CGPoint: GraphicValue {
    
    public static var zero: Self { CGPoint(x: 0.0, y: 0.0) }
    public static var one: Self { CGPoint(x: 1.0, y: 1.0) }
    public static var `default`: GraphicMetadataValue<Self> { .resolutionAlignment(.center) }
    public static var minimum: GraphicMetadataValue<Self> { .zero }
    public static var maximum: GraphicMetadataValue<Self> { .resolution }
    
    public static func lerp(at fraction: CGFloat, from leading: Self, to trailing: Self) -> Self {
        CGPoint(x: Double.lerp(at: fraction, from: leading.x, to: trailing.x),
                y: Double.lerp(at: fraction, from: leading.y, to: trailing.y))
    }
    
    public func scaled(by scale: CGFloat) -> Self {
        CGPoint(x: x.scaled(by: scale),
                y: y.scaled(by: scale))
    }
}

extension CGRect: GraphicValue {
    
    public static var zero: Self { CGRect(origin: .zero, size: .zero) }
    public static var one: Self { CGRect(origin: .zero, size: .one) }
    public static var `default`: GraphicMetadataValue<Self> { .resolution }
    public static var minimum: GraphicMetadataValue<Self> { .zero }
    public static var maximum: GraphicMetadataValue<Self> { .resolution }
    
    public static func lerp(at fraction: CGFloat, from leading: Self, to trailing: Self) -> Self {
        CGRect(origin: CGPoint.lerp(at: fraction, from: leading.origin, to: trailing.origin),
               size: CGSize.lerp(at: fraction, from: leading.size, to: trailing.size))
    }
    
    public func scaled(by scale: CGFloat) -> Self {
        CGRect(origin: origin.scaled(by: scale),
               size: size.scaled(by: scale))
    }
}

extension PixelColor: GraphicValue {
    
    public static var zero: Self { .clear }
    public static var one: Self { .white }
    public static var `default`: GraphicMetadataValue<Self> { .fixed(.white) }
    public static var minimum: GraphicMetadataValue<Self> { .fixed(.clear) }
    public static var maximum: GraphicMetadataValue<Self> { .fixed(.white) }
    
    public static func lerp(at fraction: CGFloat, from leading: Self, to trailing: Self) -> Self {
        PixelColor(red: Double.lerp(at: fraction, from: leading.red, to: trailing.red),
                   green: Double.lerp(at: fraction, from: leading.green, to: trailing.green),
                   blue: Double.lerp(at: fraction, from: leading.blue, to: trailing.blue),
                   alpha: Double.lerp(at: fraction, from: leading.alpha, to: trailing.alpha))
    }
    
    public func scaled(by scale: CGFloat) -> Self {
        PixelColor(red: red.scaled(by: scale),
                   green: green.scaled(by: scale),
                   blue: blue.scaled(by: scale),
                   alpha: alpha.scaled(by: scale))
    }
}

extension SIMD3: GraphicValue where Scalar: GraphicValue {
    
    public static var zero: Self {
        if Scalar.self == Int.self {
            return SIMD3<Int>(0, 0, 0) as! Self
        } else if Scalar.self == Double.self {
            return SIMD3<Double>(0.0, 0.0, 0.0) as! Self
        }
        fatalError("Unsupported Scalar")
    }
    public static var one: Self {
        if Scalar.self == Int.self {
            return SIMD3<Int>(1, 1, 1) as! Self
        } else if Scalar.self == Double.self {
            return SIMD3<Double>(1.0, 1.0, 1.0) as! Self
        }
        fatalError("Unsupported Scalar")
    }
    public static var `default`: GraphicMetadataValue<Self> { .resolutionAlignment(.center) }
    public static var minimum: GraphicMetadataValue<Self> { .zero }
    public static var maximum: GraphicMetadataValue<Self> { .resolution }
    
    public static func lerp(at fraction: CGFloat, from leading: Self, to trailing: Self) -> Self {
        SIMD3<Scalar>(Scalar.lerp(at: fraction, from: leading.x, to: trailing.x),
                      Scalar.lerp(at: fraction, from: leading.y, to: trailing.y),
                      Scalar.lerp(at: fraction, from: leading.z, to: trailing.z))
    }
    
    public func scaled(by scale: CGFloat) -> Self {
        SIMD3<Scalar>(x.scaled(by: scale),
                      y.scaled(by: scale),
                      z.scaled(by: scale))
    }
}

extension [Graphic.GradientStop]: GraphicValue {
    
    public static var zero: Self { [] }
    public static var one: Self { 
        [
            .init(at: 0.0, color: .clear),
            .init(at: 1.0, color: .white)
        ]
    }
    public static var `default`: GraphicMetadataValue<Self> {
        .fixed([
            .init(at: 0.0, color: .clear),
            .init(at: 1.0, color: .white)
        ])
    }
    public static var minimum: GraphicMetadataValue<Self> { .fixed([]) }
    public static var maximum: GraphicMetadataValue<Self> { 
        .fixed([
            .init(at: 0.0, color: .clear),
            .init(at: 1.0, color: .white)
        ])
    }
    
    public static func lerp(at fraction: CGFloat, from leading: Self, to trailing: Self) -> Self {
        if leading.count == trailing.count {
            var gradient: Self = []
            for (leading, trailing) in zip(leading, trailing) {
                let stop = Graphic.GradientStop(
                    at: Double.lerp(at: fraction, from: leading.location, to: trailing.location),
                    color: PixelColor.lerp(at: fraction, from: leading.color, to: trailing.color))
                gradient.append(stop)
            }
            return gradient
        }
        return leading
    }
    
    public func scaled(by scale: CGFloat) -> Self {
        var gradient: Self = []
        for stop in self {
            let stop = Graphic.GradientStop(
                at: stop.location.scaled(by: scale),
                color: stop.color.scaled(by: scale))
            gradient.append(stop)
        }
        return gradient
    }
}

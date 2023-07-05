import Foundation
import PixelColor

extension Graphic {
    
    private struct LUTUniforms {
        let count: Int32
    }
    
    public enum LUTFileFormat: String {
        case cube
    }
    
    public enum LUTError: Error {
        case fileNotFound
        case resolutionHasNonSquareAspectRatio
        case resolutionIsNotPowerOfTwo
        case resolutionUnknown
    }
    
    // MARK: Apply LUT
    
    public func applyLUT(named name: String, as fileFormat: LUTFileFormat) async throws -> Graphic {
        try await applyLUT(named: name, in: .main, as: fileFormat)
    }
    
    public func applyLUT(named name: String, in bundle: Bundle, as fileFormat: LUTFileFormat) async throws -> Graphic {
        guard let url = bundle.url(forResource: name, withExtension: fileFormat.rawValue) else {
            throw LUTError.fileNotFound
        }
        return try await applyLUT(url: url, as: fileFormat)
    }
    
    public func applyLUT(url: URL, as fileFormat: LUTFileFormat) async throws -> Graphic {
        let lut: Graphic = try await readLUT(url: url, as: fileFormat)
        return try await applyLUT(with: lut)
    }
    
    public func applyLUT(with graphic: Graphic) async throws -> Graphic {
        guard graphic.width == graphic.height else {
            throw LUTError.resolutionHasNonSquareAspectRatio
        }
        let width = Int(graphic.width)
        func isPowerOfTwo(_ n: Int) -> Bool {
            (n > 0) && ((n & (n - 1)) == 0)
        }
        guard isPowerOfTwo(width) else {
            throw LUTError.resolutionIsNotPowerOfTwo
        }
        func correctRoundingError(_ value: Double) -> Double {
            round(value * 1_000_000) / 1_000_000
        }
        var floatingCount: Double = pow(Double(width), 1.0 / 3.0)
        floatingCount = correctRoundingError(floatingCount)
        let count: Int = Int(floatingCount)
        guard Double(count) == floatingCount else {
            throw LUTError.resolutionUnknown
        }
        guard isPowerOfTwo(count) else {
            throw LUTError.resolutionIsNotPowerOfTwo
        }
        return try await Renderer.render(
            name: "Cross",
            shader: .name("lut"),
            graphics: [
                self,
                graphic
            ],
            uniforms: LUTUniforms(
                count: Int32(count)
            )
        )
    }
    
    // MARK: Read LUT
    
    public func readLUT(named name: String, as fileFormat: LUTFileFormat) async throws -> Graphic {
        try await readLUT(named: name, in: .main, as: fileFormat)
    }
    
    public func readLUT(named name: String, in bundle: Bundle, as fileFormat: LUTFileFormat) async throws -> Graphic {
        guard let url = bundle.url(forResource: name, withExtension: fileFormat.rawValue) else {
            throw LUTError.fileNotFound
        }
        return try await readLUT(url: url, as: fileFormat)
    }
    
    public func readLUT(url: URL, as fileFormat: LUTFileFormat) async throws -> Graphic {
        // ...
        return self
    }
    
    // MARK: Identity LUT
    
    public static func identityLUT() async throws -> Graphic {

        let count = 8
        let powerCount = count * count

        let partResolution = CGSize(width: powerCount,
                                    height: powerCount)
        let fullResolution = CGSize(width: powerCount * count,
                                    height: powerCount * count)

        let redGradient: Graphic = try await .gradient(direction: .horizontal, stops: [
            GradientStop(at: 0.0, color: .black),
            GradientStop(at: 1.0, color: .red),
        ], resolution: partResolution)
        let greenGradient: Graphic = try await .gradient(direction: .vertical, stops: [
            GradientStop(at: 0.0, color: .black),
            GradientStop(at: 1.0, color: .green),
        ], resolution: partResolution)
        let redGreenGradient: Graphic = try await redGradient + greenGradient

        var lut: Graphic = try await .color(.black, resolution: fullResolution)
        
        for y in 0..<count {
            let yFraction = CGFloat(y) / CGFloat(count - 1)
            for x in 0..<count {
                let xFraction = CGFloat(x) / CGFloat(count - 1)
                let i = y * count + x
                let fraction = CGFloat(i) / CGFloat(powerCount - 1)
                
                let blueColor = PixelColor(red: 0.0, green: 0.0, blue: fraction)
                let blueSolid: Graphic = try await .color(blueColor, resolution: partResolution)
                let part: Graphic = try await redGreenGradient + blueSolid
                
                let offset = CGPoint(
                    x: (xFraction - 0.5) * (fullResolution.width - partResolution.width),
                    y: (yFraction - 0.5) * (fullResolution.height - partResolution.height))
                
                lut = try await lut.transformBlended(with: part, blendingMode: .over, placement: .center, translation: offset)
            }
        }
        
        return lut
    }
}

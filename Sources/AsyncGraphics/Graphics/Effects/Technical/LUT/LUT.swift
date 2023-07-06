import Foundation
import PixelColor
import TextureMap

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
        case sizeNotFound
        case sizeNotAPowerOfTwo
        case badColorCount
        case tooHighCount
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
            name: "LUT",
            shader: .name("lut"),
            graphics: [
                self,
                graphic
            ],
            uniforms: LUTUniforms(
                count: Int32(count)
            ),
            options: Renderer.Options(
                filter: .nearest
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
        let text = try String(contentsOf: url)
        var count: Int?
        var allChannels: [Float] = []
        for row in text.split(separator: "\n") {
            if row.contains("LUT_3D_SIZE") {
                guard let countString = row.split(separator: " ").last,
                      let countNumber = Int(countString) else {
                    throw LUTError.sizeNotFound
                }
                let squareCount = countNumber
                let floatingCount = sqrt(Double(squareCount))
                count = Int(floatingCount)
                guard Double(count!) == floatingCount else {
                    throw LUTError.sizeNotAPowerOfTwo
                }
            } else if count != nil {
                let channelStrings = row.split(separator: " ")
                guard channelStrings.count == 3 else { continue }
                let channels: [Float] = channelStrings.compactMap { channelString in
                    Float(channelString)
                }
                guard channels.count == 3 else { continue }
                allChannels.append(contentsOf: channels)
                allChannels.append(1.0) /// Alpha
            }
        }
        guard let count else {
            throw LUTError.sizeNotFound
        }
        let cubeCount: Int = count * count * count
        guard allChannels.count == cubeCount * 4 else {
            throw LUTError.badColorCount
        }
        let resolution = CGSize(width: cubeCount, height: cubeCount)
        let graphic: Graphic = try .channels(allChannels, resolution: resolution)
        return graphic
    }
    
    // MARK: Identity LUT
    
    /// Identity LUT
    ///
    /// A LUT UV Map
    /// - Parameters:
    ///   - count: The resolution of the graphic is `count ^ 3`.
    ///   The default value is `8`, with a `512x512` resolution.
    public static func identityLUT(count: Int = 8, options: ContentOptions = []) async throws -> Graphic {
        
        guard count <= 16 else {
            throw LUTError.tooHighCount
        }
        
        func isPowerOfTwo(_ n: Int) -> Bool {
            (n > 0) && ((n & (n - 1)) == 0)
        }
        guard isPowerOfTwo(count) else {
            throw LUTError.resolutionIsNotPowerOfTwo
        }
        
        let squareCount = count * count
        let cubeCount = count * count * count

        let partResolution = CGSize(width: squareCount,
                                    height: squareCount)
        let fullResolution = CGSize(width: cubeCount,
                                    height: cubeCount)

        let redGradient: Graphic = try await .gradient(direction: .horizontal, stops: [
            GradientStop(at: 0.0, color: .black),
            GradientStop(at: 1.0, color: .red),
        ], resolution: partResolution, options: options)
        let greenGradient: Graphic = try await .gradient(direction: .vertical, stops: [
            GradientStop(at: 0.0, color: .black),
            GradientStop(at: 1.0, color: .green),
        ], resolution: partResolution, options: options)
        let redGreenGradient: Graphic = try await redGradient + greenGradient

        var lut: Graphic = try await .color(.black, resolution: fullResolution, options: options)
        
        for y in 0..<count {
            let yFraction = CGFloat(y) / CGFloat(count - 1)
            for x in 0..<count {
                let xFraction = CGFloat(x) / CGFloat(count - 1)
                let i = y * count + x
                let fraction = CGFloat(i) / CGFloat(squareCount - 1)
                
                let blueColor = PixelColor(red: 0.0, green: 0.0, blue: fraction)
                let blueSolid: Graphic = try await .color(blueColor, resolution: partResolution, options: options)
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

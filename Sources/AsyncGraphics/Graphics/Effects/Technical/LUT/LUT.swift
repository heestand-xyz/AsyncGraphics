import Foundation
import PixelColor
import TextureMap

extension Graphic {
    
    private struct LUTUniforms {
        let count: Int32
    }
    
    public enum LUTFormat: String {
        case cube
    }
    
    public enum LUTLayout: String {
        case square
        case linear
    }
    
    public enum LUTError: Error {
        case fileNotFound
        case resolutionHasNonSquareAspectRatio
        case resolutionIsNotPowerOfTwo
        case resolutionIsNotLinear
        case resolutionUnknown
        case sizeCorrupt
        case sizeNotFound
        case sizeNotAPowerOfTwo
        case badColorCount
        case tooHighCount
        case unknownFormat
    }
    
    // MARK: Apply LUT
    
    public func applyLUT(named name: String, format: LUTFormat) async throws -> Graphic {
        try await applyLUT(named: name, in: .main, format: format)
    }
    
    public func applyLUT(named name: String, in bundle: Bundle, format: LUTFormat) async throws -> Graphic {
        guard let url = bundle.url(named: name, format: format.rawValue) else {
            throw LUTError.fileNotFound
        }
        return try await applyLUT(url: url)
    }
    
    public func applyLUT(url: URL) async throws -> Graphic {
        let lut: Graphic = try await .readLUT(url: url, layout: .linear)
        return try await applyLUT(with: lut, layout: .linear)
    }
    
    public func applyLUT(with graphic: Graphic, layout: LUTLayout = .square) async throws -> Graphic {
        let count: Int
        switch layout {
        case .square:
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
            count = Int(floatingCount)
            guard Double(count) == floatingCount else {
                throw LUTError.resolutionUnknown
            }
            guard isPowerOfTwo(count) else {
                throw LUTError.resolutionIsNotPowerOfTwo
            }
        case .linear:
            guard graphic.width == graphic.height * graphic.height else {
                throw LUTError.resolutionIsNotLinear
            }
            count = Int(graphic.height)
        }
        return try await Renderer.render(
            name: "LUT",
            shader: .name({
                switch layout {
                case .square:
                    return "lutSquare"
                case .linear:
                    return "lutLinear"
                }
            }()),
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
    
    public static func readLUT(named name: String, format: LUTFormat, layout: LUTLayout = .square) async throws -> Graphic {
        try await readLUT(named: name, in: .main, format: format, layout: layout)
    }
    
    public static func readLUT(named name: String, in bundle: Bundle, format: LUTFormat, layout: LUTLayout = .square) async throws -> Graphic {
        guard let url = bundle.url(named: name, format: format.rawValue) else {
            throw LUTError.fileNotFound
        }
        return try await readLUT(url: url, layout: layout)
    }
    
    public static func readLUT(url: URL, layout: LUTLayout = .square) async throws -> Graphic {
        
        typealias Color = [Float]
        
        guard let fileFormat = LUTFormat(rawValue: url.pathExtension.lowercased()) else {
            throw LUTError.unknownFormat
        }
        
        let text = try String(contentsOf: url)
        
        let colorCount: Int = try sizeOfLUT(url: url)
        var blockCount: Int?
        var squareWidth: Int?
        var linearWidth: Int?
        if layout == .square {
            let floatingCount = sqrt(Double(colorCount))
            blockCount = Int(floatingCount)
            guard Double(blockCount!) == floatingCount else {
                print("AsyncGraphics - LUT size is not a power of two, please use a linear layout.")
                throw LUTError.sizeNotAPowerOfTwo
            }
            squareWidth = blockCount! * blockCount! * blockCount!
        } else {
            linearWidth = colorCount * colorCount
        }
        
        var colors: [Color] = []
        switch fileFormat {
        case .cube:
            for row in text.components(separatedBy: .newlines) {
                let channelStrings = row.components(separatedBy: .whitespaces)
                guard channelStrings.count == 3 else { continue }
                let color: Color = channelStrings.compactMap { channelString in
                    Float(channelString)
                }
                guard color.count == 3 else { continue }
                colors.append(color)
            }
        }
        
        switch layout {
        case .square:
            
            guard let blockCount, let squareWidth else {
                throw LUTError.sizeNotFound
            }
            
            guard colors.count == squareWidth * squareWidth else {
                throw LUTError.badColorCount
            }
            
            struct BlueCoordinate: Hashable {
                let x: Int
                let y: Int
            }
            var blocks: [BlueCoordinate: [[Color]]] = [:]
            for b in 0..<colorCount {
                let blueCoordinate = BlueCoordinate(x: b % blockCount, y: b / blockCount)
                var block: [[Color]] = []
                for g in 0..<colorCount {
                    var blockRow: [Color] = []
                    for r in 0..<colorCount {
                        let i = b * colorCount * colorCount + g * colorCount + r
                        let color: Color = colors[i]
                        blockRow.append(color)
                    }
                    block.append(blockRow)
                }
                blocks[blueCoordinate] = block
            }
            
            var channels: [Float] = []
            for y in 0..<blockCount {
                for iy in 0..<colorCount {
                    for x in 0..<blockCount {
                        let blueCoordinate = BlueCoordinate(x: x, y: y)
                        for ix in 0..<colorCount {
                            let color: Color = blocks[blueCoordinate]![iy][ix]
                            channels.append(contentsOf: color + [1.0])
                        }
                    }
                }
            }
            
            let resolution = CGSize(width: squareWidth, height: squareWidth)
            
            let graphic: Graphic = try .channels(channels, resolution: resolution)
            
            return graphic
            
        case .linear:
            
            guard let linearWidth else {
                throw LUTError.sizeNotFound
            }
            
            guard colors.count == linearWidth * colorCount else {
                throw LUTError.badColorCount
            }
            
            var blocks: [[[Color]]] = []
            for b in 0..<colorCount {
                var block: [[Color]] = []
                for g in 0..<colorCount {
                    var blockRow: [Color] = []
                    for r in 0..<colorCount {
                        let i = b * colorCount * colorCount + g * colorCount + r
                        let color: Color = colors[i]
                        blockRow.append(color)
                    }
                    block.append(blockRow)
                }
                blocks.append(block)
            }
            
            var channels: [Float] = []
            for iy in 0..<colorCount {
                for x in 0..<colorCount {
                    for ix in 0..<colorCount {
                        let color: Color = blocks[x][iy][ix]
                        channels.append(contentsOf: color + [1.0])
                    }
                }
            }
            
            let resolution = CGSize(width: linearWidth, height: colorCount)
            
            let graphic: Graphic = try .channels(channels, resolution: resolution)
            
            return graphic
        }
    }
    
    // MARK: Size
    
    public static func sizeOfLUT(named name: String, format: LUTFormat) throws -> Int {
        try sizeOfLUT(named: name, in: .main, format: format)
    }
    
    public static func sizeOfLUT(named name: String, in bundle: Bundle, format: LUTFormat) throws -> Int {
        guard let url = bundle.url(named: name, format: format.rawValue) else {
            throw LUTError.fileNotFound
        }
        return try sizeOfLUT(url: url)
    }
    
    public static func sizeOfLUT(url: URL) throws -> Int {
        
        typealias Color = [Float]
        
        guard let fileFormat = LUTFormat(rawValue: url.pathExtension.lowercased()) else {
            throw LUTError.unknownFormat
        }
        
        let text = try String(contentsOf: url)
        
        var colorCount: Int?
        switch fileFormat {
        case .cube:
            for row in text.components(separatedBy: .newlines) {
                if row.starts(with: "LUT_3D_SIZE") {
                    guard let countString = row.components(separatedBy: .whitespaces).last,
                          let countNumber = Int(countString) else {
                        throw LUTError.sizeCorrupt
                    }
                    colorCount = countNumber
                    break
                }
            }
        }
        
        guard let colorCount else {
            throw LUTError.sizeNotFound
        }
        
        return colorCount
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

extension Bundle {
    
    fileprivate func url(named name: String, format: String) -> URL? {
        url(forResource: name, withExtension: format) ??
        url(forResource: name, withExtension: format.uppercased())
    }
}

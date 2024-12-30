import Foundation
import PixelColor
import TextureMap

extension Graphic {
    
    private struct LUTUniforms {
        let count: Int32
    }
    
    public enum LUTFormat: String, Codable, CaseIterable, Sendable {
        case cube
    }
    
    public enum LUTLayout: String, Codable, Sendable {
        /// This layout has a one by one aspect ratio
        case square
        /// This layout has a `width` that is equal to `heigh * height`
        case linear
    }
    
    public enum LUTError: Error {
        case fileNotFound
        case resolutionIsNonSquareAspectRatio
        case resolutionIsNotPowerOfTwo
        case resolutionIsNotLinear
        case resolutionUnknown
        case sizeCorrupt
        case sizeNotFound
        case sizeNotAPowerOfTwo
        case badColorCount
        case tooSmallSize
        case tooLargeSize
        case unknownFormat
        case corruptFormat
        case dataToStringFailed
        case indexOutOfBounds
    }
    
    // MARK: Apply LUT
    
    public func applyLUT(named name: String, format: LUTFormat) async throws -> Graphic {
        try await applyLUT(named: name, in: .main, format: format)
    }
    
    public func applyLUT(named name: String, in bundle: Bundle, format: LUTFormat) async throws -> Graphic {
        guard let url = bundle.url(named: name, format: format) else {
            throw LUTError.fileNotFound
        }
        return try await applyLUT(url: url)
    }
    
    public func applyLUT(url: URL) async throws -> Graphic {
        let layout: LUTLayout = try Self.idealLayoutOfLUT(url: url)
        let lut: Graphic = try await .readLUT(url: url, layout: layout)
        return try await applyLUT(with: lut, layout: layout)
    }
    
    public func applyLUT(
        with graphic: Graphic,
        layout: LUTLayout? = nil,
        options: EffectOptions = []
    ) async throws -> Graphic {
        
        var layout: LUTLayout! = layout
        if layout == nil {
            layout = try graphic.layoutOfLUT()
        }
        
        let count: Int
        switch layout! {
        case .square:
            guard graphic.width == graphic.height else {
                throw LUTError.resolutionIsNonSquareAspectRatio
            }
            let width = Int(graphic.width)
            guard Self.isPowerOfTwo(width) else {
                throw LUTError.resolutionIsNotPowerOfTwo
            }
            count = try Self.cubeRoot(width)
            guard Self.isPowerOfTwo(count) else {
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
                switch layout! {
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
                filter: .nearest,
                targetSourceTexture: options.contains(.replace)
            )
        )
    }
    
    // MARK: Read LUT
    
    public static func readLUT(named name: String, format: LUTFormat, layout: LUTLayout? = nil) async throws -> Graphic {
        try await readLUT(named: name, in: .main, format: format, layout: layout)
    }
    
    public static func readLUT(named name: String, in bundle: Bundle, format: LUTFormat, layout: LUTLayout? = nil) async throws -> Graphic {
        guard let url = bundle.url(named: name, format: format) else {
            throw LUTError.fileNotFound
        }
        return try await readLUT(url: url, layout: layout)
    }
    
    public static func readLUT(url: URL, layout: LUTLayout? = nil) async throws -> Graphic {
        
        guard let format = LUTFormat(rawValue: url.pathExtension.lowercased()) else {
            throw LUTError.unknownFormat
        }
        
        let data = try Data(contentsOf: url)
        
        return try await readLUT(data: data, format: format, layout: layout)
    }
        
    public static func readLUT(data: Data, format: LUTFormat, layout: LUTLayout? = nil) async throws -> Graphic {
        
        var layout: LUTLayout! = layout
        if layout == nil {
            layout = try idealLayoutOfLUT(data: data, format: format)
        }
        
        typealias Color = [Float]
        
        guard let text = String(data: data, encoding: .utf8) else {
            throw LUTError.dataToStringFailed
        }
            
        let colorCount: Int = try sizeOfLUT(data: data, format: format)
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
        switch format {
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
        
        switch layout! {
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
    
    // MARK: Size of LUT
    
    public static func sizeOfLUT(named name: String, format: LUTFormat) throws -> Int {
        try sizeOfLUT(named: name, in: .main, format: format)
    }
    
    public static func sizeOfLUT(named name: String, in bundle: Bundle, format: LUTFormat) throws -> Int {
        guard let url = bundle.url(named: name, format: format) else {
            throw LUTError.fileNotFound
        }
        return try sizeOfLUT(url: url)
    }
    
    public static func sizeOfLUT(url: URL) throws -> Int {
        
        typealias Color = [Float]
        
        guard let format = LUTFormat(rawValue: url.pathExtension.lowercased()) else {
            throw LUTError.unknownFormat
        }
        
        let data = try Data(contentsOf: url)
        
        return try sizeOfLUT(data: data, format: format)
    }
    
    public static func sizeOfLUT(data: Data, format: LUTFormat) throws -> Int {
        
        guard let text = String(data: data, encoding: .utf8) else {
            throw LUTError.dataToStringFailed
        }
        
        var colorCount: Int?
        switch format {
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
    
    public func sizeOfLUT() throws -> Int {
        
        if width == height {
            
            let blockCount = try Self.cubeRoot(Int(width))
            
            return blockCount * blockCount
            
        } else {
            
            guard width == height * height else {
                throw LUTError.resolutionIsNotLinear
            }
            
            return Int(height)
        }
    }
    
    // MARK: Layout
    
    public static func idealLayoutOfLUT(named name: String, format: LUTFormat) throws -> LUTLayout {
        try idealLayoutOfLUT(named: name, in: .main, format: format)
    }
    
    public static func idealLayoutOfLUT(named name: String, in bundle: Bundle, format: LUTFormat) throws -> LUTLayout {
        guard let url = bundle.url(named: name, format: format) else {
            throw LUTError.fileNotFound
        }
        return try idealLayoutOfLUT(url: url)
    }
    
    public static func idealLayoutOfLUT(url: URL) throws -> LUTLayout {
        
        typealias Color = [Float]
        
        guard let format = LUTFormat(rawValue: url.pathExtension.lowercased()) else {
            throw LUTError.unknownFormat
        }
        
        let data = try Data(contentsOf: url)
        
        return try idealLayoutOfLUT(data: data, format: format)
    }
    
    public static func idealLayoutOfLUT(data: Data, format: LUTFormat) throws -> LUTLayout {
        
        let size: Int = try sizeOfLUT(data: data, format: format)
        
        return idealLayoutOfLUT(size: size)
    }
    
    public static func idealLayoutOfLUT(size: Int) -> LUTLayout {
        
        if isPowerOfTwo(size) {
            return .square
        } else {
            return .linear
        }
    }
    
    public func layoutOfLUT() throws -> LUTLayout {
        
        if width == height {

            _ = try Self.cubeRoot(Int(width))
            
            return .square
            
        } else {
            
            guard width == height * height else {
                throw LUTError.resolutionIsNotLinear
            }
            
            return .linear
        }
    }
    
    // MARK: Write LUT
    
    /// Writes a the LUT graphic to data in a CUBE format
    /// - Parameter layout: The layout of the LUT
    /// - Returns: Data of a utf8 String for a .cube file
    public func writeLUT(layout: LUTLayout = .square) async throws -> Data {
        
        var count: Int?
        let size: Int
        switch layout {
        case .square:
            guard width == height else {
                throw LUTError.resolutionIsNonSquareAspectRatio
            }
            count = try Self.cubeRoot(Int(width))
            size = count! * count!
        case .linear:
            guard width == height * height else {
                throw LUTError.resolutionUnknown
            }
            size = Int(height)
        }
        
        var lut = "// Created with AsyncGraphics\n\nLUT_3D_SIZE \(size)\n\n"
        
        let channels: [Float] = try await channels.map(Float.init)
        
        switch layout {
        case .square:
            for y in 0..<count! {
                for x in 0..<count! {
                    for iy in 0..<size {
                        for ix in 0..<size {
                            let _x = x * size + ix
                            let _y = y * size + iy
                            let _i = _y * size * count! * 4 + _x * 4
                            let red = String(format: "%.6f", channels[_i])
                            let green = String(format: "%.6f", channels[_i + 1])
                            let blue = String(format: "%.6f", channels[_i + 2])
                            let row = "\(red) \(green) \(blue)"
                            lut += "\(row)\n"
                        }
                    }
                }
            }
        case .linear:
            for x in 0..<size {
                for iy in 0..<size {
                    for ix in 0..<size {
                        let _x = x * size + ix
                        let _i = iy * size * size * 4 + _x * 4
                        let red = String(format: "%.6f", channels[_i])
                        let green = String(format: "%.6f", channels[_i + 1])
                        let blue = String(format: "%.6f", channels[_i + 2])
                        let row = "\(red) \(green) \(blue)"
                        lut += "\(row)\n"
                    }
                }
            }
        }
        
        guard let data: Data = lut.data(using: .utf8) else {
            throw LUTError.corruptFormat
        }
        
        return data
    }
    
    // MARK: Identity LUT
    
    /// Default LUT with no adjustments.
    ///
    /// A LUT UV Map
    /// - Parameters:
    ///   - size: The color resolution of the LUT.
    ///   Minimum allowed size is 2.
    ///   Maximum allowed size is 64.
    public static func identityLUT(size: Int = 16, layout: LUTLayout = .square, options: ContentOptions = []) async throws -> Graphic {
        
        guard size >= 2 else {
            throw LUTError.tooSmallSize
        }
        
        guard size <= 64 else {
            throw LUTError.tooLargeSize
        }
        
        let partResolution = CGSize(width: size,
                                    height: size)
        
        let padding = (1.0 / CGFloat(size)) / 2
        
        let redGradient: Graphic = try await .gradient(direction: .horizontal, stops: [
            GradientStop(at: padding, color: .black),
            GradientStop(at: 1.0 - padding, color: .rawRed),
        ], resolution: partResolution, options: options)
        let greenGradient: Graphic = try await .gradient(direction: .vertical, stops: [
            GradientStop(at: padding, color: .black),
            GradientStop(at: 1.0 - padding, color: .rawGreen),
        ], resolution: partResolution, options: options)
        let redGreenGradient: Graphic = try await redGradient + greenGradient

        switch layout {
        case .square:
            
            guard isPowerOfTwo(size) else {
                throw LUTError.resolutionIsNotPowerOfTwo
            }
            
            let count = Int(sqrt(Double(size)))
            
            let squareCount = count * count
            let cubeCount = count * count * count

            let fullResolution = CGSize(width: cubeCount,
                                        height: cubeCount)

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
                    
                    lut = try await lut.transformBlended(with: part, blendingMode: .over, placement: .fixed, translation: offset)
                }
            }
            
            return lut
            
        case .linear:
            
            let fullResolution = CGSize(width: size * size,
                                        height: size)

            var lut: Graphic = try await .color(.black, resolution: fullResolution, options: options)
            
            for x in 0..<size {
                let fraction = CGFloat(x) / CGFloat(size - 1)
                
                let blueColor = PixelColor(red: 0.0, green: 0.0, blue: fraction)
                let blueSolid: Graphic = try await .color(blueColor, resolution: partResolution, options: options)
                let part: Graphic = try await redGreenGradient + blueSolid
                
                let offset = CGPoint(
                    x: (fraction - 0.5) * (fullResolution.width - partResolution.width),
                    y: 0.0)
                
                lut = try await lut.transformBlended(with: part, blendingMode: .over, placement: .fixed, translation: offset)
            }
            
            return lut
        }
    }
    
    // MARK: Sample of LUT
    
    /// A sample is a 2D slice of the 3D LUT
    public func sampleOfLUT(at index: Int, layout: LUTLayout) async throws -> Graphic {
        
        let size: Int = try sizeOfLUT()
        
        guard index >= 0, index < size else {
            throw LUTError.indexOutOfBounds
        }
        
        let origin: CGPoint
        switch layout {
        case .square:
            
            let blockSize = Int(sqrt(Double(size)))
            
            origin = CGPoint(x: CGFloat(index % blockSize) * CGFloat(size),
                             y: CGFloat(index / blockSize) * CGFloat(size))
            
        case .linear:
            
            origin = CGPoint(x: index * size, y: 0)
        }

        let frame = CGRect(origin: origin,
                           size: CGSize(width: size,
                                        height: size))
        
        return try await crop(to: frame)
    }
    
    // MARK: Helpers
    
    private static func isPowerOfTwo(_ n: Int) -> Bool {
        (n > 0) && ((n & (n - 1)) == 0)
    }
    
    enum CubeRootError: Error {
        case nonIntAfterCubeRoot
    }
    
    private static func cubeRoot(_ value: Int) throws -> Int {
        var cubedValue: Double = pow(Double(value), 1.0 / 3.0)
        cubedValue = correctRoundingError(cubedValue)
        let intValue = Int(cubedValue)
        guard Double(intValue) == cubedValue else {
            throw CubeRootError.nonIntAfterCubeRoot
        }
        return intValue
    }
    
    private static func correctRoundingError(_ value: Double) -> Double {
        round(value * 1_000_000) / 1_000_000
    }
}

extension Bundle {
    
    fileprivate func url(named name: String, format: Graphic.LUTFormat) -> URL? {
        url(forResource: name, withExtension: format.rawValue) ??
        url(forResource: name, withExtension: format.rawValue.uppercased())
    }
}

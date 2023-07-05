import Foundation

extension Graphic {
    
    public enum LUTFileFormat: String {
        case cube
    }
    
    public enum LUTError: Error {
        case fileNotFound
        case nonOneAspectRatio
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
            throw LUTError.nonOneAspectRatio
        }
        // ...
        return self
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
    
    public static func identityLUT(resolution: CGSize) async throws -> Graphic {
        var lut: Graphic = try await .color(.clear, resolution: resolution)
        // ...
        return lut
    }
}

import XCTest
@testable import AsyncGraphics
import TextureMap
import PixelColor

final class LiveGraphicsTests: XCTestCase {
    
    func testImage() async throws {

        let imageTexture: Graphic = try await .image(named: "Kite", in: .module)

        _ = try await imageTexture.image
    }
    
    func testPixels() async throws {
        
        let imageTexture: Graphic = try await .image(named: "Kite", in: .module)
                
        let firstPixel: PixelColor = try await imageTexture.firstPixel
        
        let firstColor = PixelColor(red: 0.4392156862745098,
                                    green: 0.2196078431372549,
                                    blue: 0.00392156862745098,
                                    alpha: 1.0)

        XCTAssertEqual(firstColor, firstPixel)
    }
    
    func testReduce() async throws {
        
        let imageTexture: Graphic = try await .image(named: "Kite", in: .module)

        let reducedTexture: Graphic = try await imageTexture.reduce(by: .average, in: .y)
        
        XCTAssertEqual(reducedTexture.resolution.width, imageTexture.resolution.width)
        XCTAssertEqual(reducedTexture.resolution.height, 1)
        
        let reducedBrightness: CGFloat = try await reducedTexture.firstPixel.brightness
        XCTAssertNotEqual(0.0, reducedBrightness)
    }
    
    @available(iOS 14.0, tvOS 14, macOS 11, *)
    func testBits() async throws {
        
        let imageTexture: Graphic = try await .image(named: "Kite", in: .module)
        
        XCTAssertEqual(imageTexture.bits, ._8)
        
        let bitTexture: Graphic = try await imageTexture.with(bits: ._16)
        
        XCTAssertEqual(bitTexture.bits, ._16)
    }
    
    func testInvert() async throws {

        let image: Graphic = try await .image(named: "Kite", in: .module)
        print("--> image:", try await image.reduce(by: .average))

        let inverted: Graphic = try await image.inverted()
        print("--> inverted:", try await inverted.reduce(by: .average))
        let invertedIsEqual: Bool = try await inverted.isEqual(to: image)
        XCTAssertFalse(invertedIsEqual)

        let original: Graphic = try await inverted.inverted()
        print("--> original:", try await original.reduce(by: .average))
        let originalIsEqual: Bool = try await original.isEqual(to: image)
        XCTAssertTrue(originalIsEqual)
    }
}

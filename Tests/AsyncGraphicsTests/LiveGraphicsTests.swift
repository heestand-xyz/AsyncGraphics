import XCTest
@testable import AsyncGraphics
import TextureMap
import PixelColor

final class LiveGraphicsTests: XCTestCase {
    
    func testImage() async throws {

        let imageTexture: Graphic = try await .image(named: "Kite", in: .module)

        _ = try await imageTexture.image
    }
    
    func testReduce() async throws {
        
        let imageTexture: Graphic = try await .image(named: "Kite", in: .module)

        let reducedTexture: Graphic = try await imageTexture.reduceToRow(by: .average)
        
        XCTAssertEqual(reducedTexture.resolution.width, imageTexture.resolution.width)
        XCTAssertEqual(reducedTexture.resolution.height, 1)
        
        let reducedBrightness: CGFloat = try await reducedTexture.firstPixelColor.brightness
        XCTAssertNotEqual(0.0, reducedBrightness)
    }
    
    @available(iOS 14.0, tvOS 14, macOS 11, *)
    func testBits() async throws {
        
        let imageTexture: Graphic = try await .image(named: "Kite", in: .module)
        
        XCTAssertEqual(imageTexture.bits, ._8)
        
        let bitTexture: Graphic = try await imageTexture.withBits(.bit16)
        
        XCTAssertEqual(bitTexture.bits, ._16)
    }
    
    func testInvert() async throws {
        
        let image: Graphic = try await .image(named: "Kite", in: .module)
        
        let inverted: Graphic = try await image.inverted()
        let invertedIsEqual: Bool = try await inverted.isPixelsEqual(to: image)
        XCTAssertFalse(invertedIsEqual)
        
        let invertedBack: Graphic = try await inverted.inverted()
        let invertedBackIsEqual: Bool = try await invertedBack.isPixelsEqual(to: image)
        XCTAssertTrue(invertedBackIsEqual)
    }
    
    func testBlend() async throws {
        
        let image1: Graphic = try await .image(named: "Kite", in: .module)
        let image2: Graphic = try await .image(named: "City", in: .module)
        
        _ = try await image1.blended(with: image2, blendingMode: .add, placement: .fill)
    }
    
    func testTriangle() async throws {
        
        for length in 1...1000 {
            guard length % 100 == 0 else { continue }
            let triangle: Graphic = try await .polygon(count: 3, resolution: CGSize(width: length, height: length))
            let color = try await triangle.averagePixelColor
            print("Triangle Test at \(length)", "alpha:", color.alpha, "brightness:", color.brightness)
            XCTAssertNotEqual(color.alpha, 0.0, "length: \(length)")
        }
    }
}

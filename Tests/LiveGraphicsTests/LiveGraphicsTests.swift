import XCTest
@testable import LiveGraphics

final class LiveGraphicsTests: XCTestCase {
    
    func testImage() async throws {
        
        let image = await Texture(named: "Kite")
        
        XCTAssertNotNil(image.metalTexture)
    }
    
    func testInvert() async throws {
        
        let image = await Texture(named: "Kite")
        XCTAssertNotNil(image.metalTexture)

        let inverted = await image.inverted()
        XCTAssertNotNil(inverted.metalTexture)
        XCTAssertNotEqual(image, inverted)
        
        let original = await inverted.inverted()
        XCTAssertNotNil(original.metalTexture)
        XCTAssertEqual(image, original)
    }
}

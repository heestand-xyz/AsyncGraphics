import XCTest
@testable import LiveGraphics

final class LiveGraphicsTests: XCTestCase {
    
    func testImage() async throws {
        
        let image = await Texture(named: "Kite")
        
        XCTAssertNotNil(image.rawTexture)
    }
    
    func testInvert() async throws {
        
        let image = await Texture(named: "Kite")
        XCTAssertNotNil(image.rawTexture)

        let inverted = await image.inverted()
        XCTAssertNotNil(inverted.rawTexture)
        XCTAssertNotEqual(image, inverted)
        
        let original = await inverted.inverted()
        XCTAssertNotNil(original.rawTexture)
        XCTAssertEqual(image, original)
    }
}

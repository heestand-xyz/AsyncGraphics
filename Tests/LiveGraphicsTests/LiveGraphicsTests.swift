import XCTest
@testable import LiveGraphics

final class LiveGraphicsTests: XCTestCase {
    
    func testImage() async throws {
        
        let image = await LiveFrame(named: "Kite")
        
        XCTAssertNotNil(image.texture)
    }
    
    func testInvert() async throws {
        
        let image = await LiveFrame(named: "Kite")
        XCTAssertNotNil(image.texture)

        let inverted = await image.inverted()
        XCTAssertNotNil(inverted.texture)
        XCTAssertNotEqual(image, inverted)
        
        let original = await inverted.inverted()
        XCTAssertNotNil(original.texture)
        XCTAssertEqual(image, original)
    }
}

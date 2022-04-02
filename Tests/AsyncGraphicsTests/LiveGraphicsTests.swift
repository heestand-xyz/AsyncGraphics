import XCTest
@testable import AsyncGraphics
import TextureMap

final class LiveGraphicsTests: XCTestCase {
    
    func testImage() async throws {
        
        let imageTexture: AGTexture = try await .image(named: "Kite", in: .module)
            
        _ = try await imageTexture.image
    }
    
//    func testInvert() async throws {
//
//        let image: AGTexture = await .image(named: "Kite")
//        XCTAssertNotNil(image.metalTexture)
//
//        let inverted = await image.inverted()
//        XCTAssertNotNil(inverted.metalTexture)
//        XCTAssertNotEqual(image, inverted)
//
//        let original = await inverted.inverted()
//        XCTAssertNotNil(original.metalTexture)
//        XCTAssertEqual(image, original)
//    }
}

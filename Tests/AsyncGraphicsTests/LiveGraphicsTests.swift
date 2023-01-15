import XCTest
@testable import AsyncGraphics
import TextureMap
import PixelColor

// This class is for testing the different functionalities provided by AsyncGraphics library
final class LiveGraphicsTests: XCTestCase {
    
    // Test to check the loading of an image as a texture
    func testImage() async throws {
        // Loading an image texture named 'Kite' from the current module
        let imageTexture: Graphic = try await .image(named: "Kite", in: .module)
        // Get the image representation of the texture
        _ = try await imageTexture.image
    }
    
    // Test to check the functionality of getting the first pixel color of an image texture
    func testPixels() async throws {
        // Loading an image texture named 'Kite' from the current module
        let imageTexture: Graphic = try await .image(named: "Kite", in: .module)
        // Get the first pixel color of the texture
        let firstPixel: PixelColor = try await imageTexture.firstPixelColor
        // Defining a color to be compared with the first pixel color of the texture
        let firstColor = PixelColor(red: 0.4392156862745098,
                                    green: 0.2196078431372549,
                                    blue: 0.00392156862745098,
                                    alpha: 1.0)
        // Asserting that the first pixel color of the texture is equal to the defined color
        XCTAssertEqual(firstColor, firstPixel)
    }
    
    // Test to check the functionality of reducing an image texture
    func testReduce() async throws {
        // Loading an image texture named 'Kite' from the current module
        let imageTexture: Graphic = try await .image(named: "Kite", in: .module)
        // Reduce the image texture by averaging the pixels in Y axis
        let reducedTexture: Graphic = try await imageTexture.reduce(by: .average, in: .y)
        // Asserting that the width of the reduced texture is equal to the width of the original texture
        XCTAssertEqual(reducedTexture.resolution.width, imageTexture.resolution.width)
        // Asserting that the height of the reduced texture is equal to 1
        XCTAssertEqual(reducedTexture.resolution.height, 1)
        // Get the brightness of the first pixel of the reduced texture
        let reducedBrightness: CGFloat = try await reducedTexture.firstPixelColor.brightness
        // Asserting that the brightness of the first pixel of the reduced texture is not equal to 0
        XCTAssertNotEqual(0.0, reducedBrightness)
    }
    
    // Test to check the functionality of changing the bit depth of an image texture
    @available(iOS 14.0, tvOS 14, macOS 11, *)
    func testBits() async throws {
        
        // Loading an image texture named 'Kite' from the current module
        let imageTexture: Graphic = try await .image(named: "Kite", in: .module)
        // Asserting that the bit depth of the original texture is 8
        XCTAssertEqual(imageTexture.bits, ._8)
        // Increasing the bit depth of the texture to 16    

        let bitTexture: Graphic = try await imageTexture.with(bits: ._16)
        // Asserting that the bit depth of the texture is now 16
        XCTAssertEqual(bitTexture.bits, ._16)
    }
    
   // Test to check the functionality of inverting an image texture
func testInvert() async throws {
    
    // Loading an image texture named 'Kite' from the current module
    let image: Graphic = try await .image(named: "Kite", in: .module)
    // Inverting the original image texture
    let inverted: Graphic = try await image.inverted()
    // Checking if the inverted texture is equal to the original texture
    let invertedIsEqual: Bool = try await inverted.isEqual(to: image)
    // Asserting that the inverted texture is not equal to the original texture
    XCTAssertFalse(invertedIsEqual)
    // Inverting the inverted texture
    let invertedBack: Graphic = try await inverted.inverted()
    // Checking if the inverted back texture is equal to the original texture
    let invertedBackIsEqual: Bool = try await invertedBack.isEqual(to: image)
    // Asserting that the inverted back texture is equal to the original texture
    XCTAssertTrue(invertedBackIsEqual)
}

// Test to check the functionality of blending two image textures
func testBlend() async throws {
    
    // Loading two image textures named 'Kite' and 'City' from the current module
    let image1: Graphic = try await .image(named: "Kite", in: .module)
    let image2: Graphic = try await .image(named: "City", in: .module)
    // Blending the two image textures using the 'add' blending mode and filling the entire output image
    _ = try await image1.blended(graphic: image2, blendingMode: .add, placement: .fill)
}

// Test to check the functionality of creating a circle texture
func testCircle() async throws {
    
    // Create a circle texture with width and height of 1920 and 1080
    _ = try await Graphic.circle(size: CGSize(width: 1920, height: 1080))
    }
}


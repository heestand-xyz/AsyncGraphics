//import XCTest
//@testable import AsyncGraphics
//
//final class CodableGraphicsTests: XCTestCase {
//    
//    let resolution = CGSize(width: 1000, height: 1000)
//    let resolution3D = SIMD3<Int>(100, 100, 100)
//    
//    func testType() async throws {
//        
//        for type in CodableGraphicType.allCases {
//            let instance: CodableGraphic = type.instance()
//            XCTAssertEqual(type, instance.type)
//        }
//        
//        for type in CodableGraphic3DType.allCases {
//            let instance: CodableGraphic3D = type.instance()
//            XCTAssertEqual(type, instance.type)
//        }
//    }
//    
//    func testRender() async throws {
//        
//        for type in CodableGraphicType.allCases {
//            let instance: CodableGraphic = type.instance()
//            if let content = instance as? ContentGraphic {
//                _ = try await content.render(at: resolution, options: [])
//            }
//        }
//        
//        for type in CodableGraphic3DType.allCases {
//            let instance: CodableGraphic3D = type.instance()
//            if let content = instance as? ContentGraphic3D {
//                _ = try await content.render(at: resolution3D, options: [])
//            }
//        }
//    }
//}

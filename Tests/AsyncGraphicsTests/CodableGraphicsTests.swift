import XCTest
import SwiftUI
import Spatial
@testable import AsyncGraphics

final class CodableGraphicsTests: XCTestCase {
    
    let resolution = CGSize(width: 1000, height: 1000)
    let resolution3D = Size3D(width: 100, height: 100, depth: 100)
    
    func testType() async throws {
        
        for type in CodableGraphicType.allCases {
            let instance: CodableGraphicProtocol = type.instance()
            XCTAssertEqual(type, instance.type)
        }
        
        for type in CodableGraphic3DType.allCases {
            let instance: CodableGraphic3DProtocol = type.instance()
            XCTAssertEqual(type, instance.type)
        }
    }
    
    func testRender() async throws {
        
        for type in CodableGraphicType.allCases {
            let instance: CodableGraphicProtocol = type.instance()
            if let content = instance as? ContentGraphicProtocol {
                _ = try await content.render(at: resolution, options: [])
            }
        }
        
        for type in CodableGraphic3DType.allCases {
            let instance: CodableGraphic3DProtocol = type.instance()
            if let content = instance as? ContentGraphic3DProtocol {
                _ = try await content.render(at: resolution3D, options: [])
            }
        }
    }
    
    func testVisible() throws {
        
        let scaleProperty: CodableGraphic.Content.Solid.Noise.Property = .scale
        let isRandomProperty: CodableGraphic.Content.Solid.Noise.Property = .isRandom

        let noise = CodableGraphic.Content.Solid.Noise()
        noise.isRandom.value = .fixed(true)
        XCTAssert(noise.isVisible(property: scaleProperty, at: resolution) == false)

        let instance = noise.type.instance()
        if let valueProperty = instance.properties.first(where: { $0.key == isRandomProperty.rawValue }) as? AnyGraphicValueProperty {
            try valueProperty.setValue(.fixed(true))
        }
        XCTAssert(instance.isVisible(propertyKey: scaleProperty.rawValue, at: resolution) == false)
    }
    
    func testVariants() throws {
        
        let variants = CodableGraphic.Content.Shape.Arc.Variant.allCases
        let lengthProperty = CodableGraphic.Content.Shape.Arc.Property.length

        let arcs = CodableGraphic.Content.Shape.Arc.variants()
        for arc in arcs {
            let variant = variants.first(where: { $0.description == arc.description })!
            let length: Angle = try (arc.instance.properties.first(where: {
                $0.key == lengthProperty.rawValue
            }) as! AnyGraphicValueProperty).getValue().eval(at: resolution)
            switch variant {
            case .length45:
                XCTAssertEqual(length, .degrees(45))
            case .length90:
                XCTAssertEqual(length, .degrees(90))
            case .length120:
                XCTAssertEqual(length, .degrees(120))
            case .length180:
                XCTAssertEqual(length, .degrees(180))
            }
        }
    }
}

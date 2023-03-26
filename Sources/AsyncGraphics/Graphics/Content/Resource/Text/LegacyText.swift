//
//  Created by Anton Heestand on 2022-08-08.
//

import CoreGraphics
import CoreGraphicsExtensions
import TextureMap
import PixelColor
import SpriteKit

extension Graphic {
    
    #if os(macOS)
    @available(*, deprecated)
    public typealias LegacyTextFont = NSFont
    #else
    @available(*, deprecated)
    public typealias LegacyTextFont = UIFont
    #endif
    
    @available(*, deprecated)
    public enum LegacyTextHorizontalAlignment {
        
        case left
        case center
        case right
        
        var mode: SKLabelHorizontalAlignmentMode  {
            switch self {
            case .left:
                return .left
            case .center:
                return .center
            case .right:
                return .right
            }
        }
    }
    
    @available(*, deprecated)
    public enum LegacyTextVerticalAlignment {
        
        case top
        case center
        case bottom
        
        var mode: SKLabelVerticalAlignmentMode  {
            switch self {
            case .top:
                return .top
            case .center:
                return .center
            case .bottom:
                return .bottom
            }
        }
    }
    
    @available(*, deprecated)
    enum LegacyTextError: LocalizedError {
        
        case renderFailed
        
        var errorDescription: String? {
            switch self {
            case .renderFailed:
                return "AsyncGraphics - Graphic - Text - Render Failed"
            }
        }
    }
    
//    @available(*, deprecated)
    public static func text(_ text: String,
                            font: LegacyTextFont,
                            center: CGPoint? = nil,
                            horizontalAlignment: LegacyTextHorizontalAlignment = .center,
                            verticalAlignment: LegacyTextVerticalAlignment = .center,
                            color: PixelColor = .white,
                            backgroundColor: PixelColor = .black,
                            resolution: CGSize,
                            options: ContentOptions = ContentOptions()) async throws -> Graphic {
        
        let center: CGPoint = center ?? (resolution.asPoint / 2)
        
        let texture: MTLTexture = try await withCheckedThrowingContinuation { continuation in
            
            DispatchQueue.main.async {
                
                let scene = SKScene(size: resolution)
                #if os(macOS)
                scene.backgroundColor = backgroundColor.nsColor
                #else
                scene.backgroundColor = backgroundColor.uiColor
                #endif
                
                let label = SKLabelNode()
                label.text = text
                label.numberOfLines = 0
                label.position = center
                label.fontName = font.fontName
                label.fontSize = font.pointSize
                #if os(macOS)
                label.fontColor = color.nsColor
                #else
                label.fontColor = color.uiColor
                #endif
                label.horizontalAlignmentMode = horizontalAlignment.mode
                label.verticalAlignmentMode = verticalAlignment.mode
                scene.addChild(label)

                let sceneView = SKView(frame: CGRect(origin: .zero, size: resolution))
                sceneView.allowsTransparency = backgroundColor.alpha < 1.0
                sceneView.presentScene(scene)

                guard let skTexture: SKTexture = sceneView.texture(from: scene) else {
                    continuation.resume(throwing: LegacyTextError.renderFailed)
                    return
                }
                
                DispatchQueue.global(qos: .background).async {
                    
                    let cgImage: CGImage = skTexture.cgImage()
                    
                    do {
                        
                        let texture: MTLTexture = try TextureMap.texture(cgImage: cgImage)
                        
                        DispatchQueue.main.async {
                            continuation.resume(returning: texture)
                        }
                        
                    } catch {
                        DispatchQueue.main.async {
                            continuation.resume(throwing: error)
                        }
                    }
                }
            }
        }
        
        var graphic = Graphic(name: "Text",
                              texture: texture,
                              bits: ._8,
                              colorSpace: options.colorSpace)
        
        if options.bits != ._8 {
            graphic = try await graphic.bits(options.bits)
        }
        
        return graphic
    }
}

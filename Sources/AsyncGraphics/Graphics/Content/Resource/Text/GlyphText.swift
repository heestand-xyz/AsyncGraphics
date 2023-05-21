//
//  Created by Anton Heestand on 2022-08-08.
//

import Foundation
#if os(macOS)
import AppKit
#else
import UIKit
#endif
import CoreGraphics
import CoreGraphicsExtensions
import TextureMap
import PixelColor
import CoreText

// https://metalbyexample.com/text-3d/

extension Graphic {
    
    #if os(macOS)
    typealias GlyphTextFont = NSFont
    #else
    typealias GlyphTextFont = UIFont
    #endif
    
    enum GlyphTextHorizontalAlignment {
        
        case left
        case center
        case right
    }
    
    enum GlyphTextVerticalAlignment {
        
        case top
        case center
        case bottom
    }
    
    enum GlyphTextError: LocalizedError {
        
        case renderFailed
        case noRunFound
        
        var errorDescription: String? {
            switch self {
            case .renderFailed:
                return "AsyncGraphics - Graphic - Text - Render Failed"
            case .noRunFound:
                return "AsyncGraphics - Graphic - Text - No Run Found"
            }
        }
    }
    
    static func glyphText(_ text: String,
                          fontSize: CGFloat,
                          center: CGPoint? = nil,
                          horizontalAlignment: GlyphTextHorizontalAlignment = .center,
                          verticalAlignment: GlyphTextVerticalAlignment = .center,
                          color: PixelColor = .white,
                          backgroundColor: PixelColor = .black,
                          options: ContentOptions = ContentOptions()) async throws -> Graphic {
        
//        let resolution = CGSize(width: 1_000, height: 1_000)
//        let center: CGPoint = center ?? (resolution.asPoint / 2)

        let font = CTFontCreateWithName("HelveticaNeue-UltraLight" as CFString, fontSize, nil)
        
        let textFont = GlyphTextFont.systemFont(ofSize: fontSize)
        let attributes: [NSAttributedString.Key: Any] = [.font: textFont]
        let attributedString = NSAttributedString(string: text, attributes: attributes)

        let typesetter = CTTypesetterCreateWithAttributedString(attributedString)
        let line = CTTypesetterCreateLine(typesetter, CFRange(location: 0, length: 0))
        let runs: [CTRun] = CTLineGetGlyphRuns(line) as! [CTRun]
        
        guard let run = runs.first else {
            throw GlyphTextError.noRunFound
        }
                    
        let glyphCount = CTRunGetGlyphCount(run)
        
        var glyphPositions = [CGPoint](repeating: .zero, count: Int(glyphCount))
        CTRunGetPositions(run, CFRange(location: 0, length: 0), &glyphPositions)
        
        var glyphs = [CGGlyph](repeating: 0, count: Int(glyphCount))
        CTRunGetGlyphs(run, CFRange(location: 0, length: 0), &glyphs)
        
        print(glyphs.count, glyphPositions.count)
        
        for (glyph, glyphPosition) in zip(glyphs, glyphPositions) {
            
            var transform = CGAffineTransform(translationX: glyphPosition.x, y: glyphPosition.y)

            if let path = CTFontCreatePathForGlyph(font, glyph, &transform) {
                // Use the path here
            }
        }
    
        throw GlyphTextError.renderFailed
//        var graphic = Graphic(name: "Text",
//                              texture: texture,
//                              bits: ._8,
//                              colorSpace: options.colorSpace)
//
//        if options.bits != ._8 {
//            graphic = try await graphic.bits(options.bits)
//        }
//
//        return graphic
    }
}

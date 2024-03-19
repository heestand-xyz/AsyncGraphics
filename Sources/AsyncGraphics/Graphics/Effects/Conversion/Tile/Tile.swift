//
//  File.swift
//  
//
//  Created by Anton on 2024-03-19.
//

import Foundation
import CoreGraphicsExtensions

extension Graphic {
    
    public enum TileError: Error {
        case badResolution(CGSize)
        case badCount(Tile.Size)
    }
    
    /// Tile render a ``Graphic`` with a very large resolution.
    /// - Parameters:
    ///   - count: The number of tiles.
    ///   - padding: A padding relative to the final resolution, it can be useful to use when working with distortion effects, tho has no effect on color effects.
    ///   - resolution: The final resolution.
    ///   - render: A callback where you render a tile of ``Graphic``. Pass the tile struct to the shape you are rendering.
    /// - Returns: A tilled ``Graphic``.
    public static func tiled(
        count: Tile.Size,
        padding: CGFloat = 0.0,
        resolution: CGSize,
        render: (Tile) async throws -> Graphic
    ) async throws -> Graphic {
        
        guard count.width > 0,
              count.height > 0 else {
            throw TileError.badCount(count)
        }
        guard resolution.width > CGFloat(count.width),
              resolution.height > CGFloat(count.height) else {
            throw TileError.badResolution(resolution)
        }
        
        let tilePadding = padding / (resolution.height / CGFloat(count.height))
        
        var gridGraphic: Graphic?
        for y in 0..<count.height {
            var rowGraphic: Graphic?
            for x in 0..<count.width {
                
                let tile = Tile(
                    origin: .init(
                        x: x,
                        y: y),
                    count: count,
                    padding: tilePadding)
                
                var tileGraphic: Graphic = try await render(tile)
                
                if padding > 0.0 {
                    let cropOrigin = CGPoint(x: padding, y: padding)
                    let cropResolution = CGSize(
                        width: resolution.width / CGFloat(count.width),
                        height: resolution.height / CGFloat(count.height))
                    tileGraphic = try await tileGraphic.crop(
                        to: CGRect(origin: cropOrigin,
                                   size: cropResolution))
                }
                
                if let previousGraphic: Graphic = rowGraphic {
                    rowGraphic = try await previousGraphic.hStacked(with: tileGraphic)
                } else {
                    rowGraphic = tileGraphic
                }
            }
            guard let rowGraphic: Graphic else {
                fatalError("Tiel Row Graphic Not Found")
            }
            if let previousGraphic: Graphic = gridGraphic {
                gridGraphic = try await previousGraphic.vStacked(with: rowGraphic)
            } else {
                gridGraphic = rowGraphic
            }
        }
        guard let gridGraphic: Graphic else {
            fatalError("Tiel Grid Graphic Not Found")
        }
        return gridGraphic
    }
}

//
//  Graphic3DCompositionTests.swift
//  AsyncGraphics
//
//  Created by Anton Heestand with AI on 2026-09-25.
//

import AsyncGraphics
import Foundation
import PixelColor
import Spatial
import Testing


@Suite(.serialized)
struct Graphic3DCompositionTests {

    // MARK: - Tests

    @Test("Graphic3D: Fixed placement respects all 27 alignments", arguments: Self.alignments)
    func fixedPlacement(alignment: Graphic3D.Alignment3D) async throws {
        let background = try await Graphic3D.color(.clear, resolution: Size3D(width: 6, height: 6, depth: 6))
        let foreground = try await Graphic3D.color(.red, resolution: Size3D(width: 2, height: 2, depth: 2))
        let placement = alignment
        let result = try await background.blended(with: foreground, blendingMode: .over, placement: .fixed, alignment: placement)
        let voxels = try await result.voxelColors
        let originX: Int = switch placement.x {
        case .leading: 0
        case .center: 2
        case .trailing: 4
        }
        let originY: Int = switch placement.y {
        case .bottom: 0
        case .center: 2
        case .top: 4
        }
        let originZ: Int = switch placement.z {
        case .far: 0
        case .center: 2
        case .near: 4
        }
        for z in 0..<6 {
            for y in 0..<6 {
                for x in 0..<6 {
                    let inside = (originX..<originX + 2).contains(x)
                        && (originY..<originY + 2).contains(y)
                        && (originZ..<originZ + 2).contains(z)
                    #expect(abs(voxels[z][y][x].opacity - (inside ? 1.0 : 0.0)) < 0.01)
                }
            }
        }
    }

    @Test("Graphic3D: Fit and Fill scale uniformly across every axis", arguments: [0, 1, 2])
    func fitAndFill(axis: Int) async throws {
        let size = Size3D(width: axis == 0 ? 8 : 2, height: axis == 1 ? 8 : 2, depth: axis == 2 ? 8 : 2)
        let foreground = try await Graphic3D.uvw(resolution: size)
        let background = try await Graphic3D.color(.clear, resolution: Size3D(width: 8, height: 8, depth: 8))
        let fit = try await background.blended(with: foreground, blendingMode: .over, placement: .fit)
        let fitColors = try await fit.voxelColors
        #expect(fitColors[0][0][0].opacity < 0.01)
        #expect(fitColors[3][3][3].opacity > 0.99)
        let fill = try await background.blended(with: foreground, blendingMode: .over, placement: .fill)
        let fillColors = try await fill.voxelColors
        let first = fillColors[0][0][0]
        let channel = [first.red, first.green, first.blue][axis]
        // The long axis is cropped to the center quarter (the old Fill acted like Stretch).
        #expect(abs(channel - 0.390625) < 0.02)
        #expect(first.opacity > 0.99)
    }

    @Test("Graphic3D: Fill alignment chooses the cropped region")
    func fillAlignment() async throws {
        let foreground = try await Graphic3D.uvw(resolution: Size3D(width: 8, height: 2, depth: 2))
        let background = try await Graphic3D.color(.clear, resolution: Size3D(width: 8, height: 8, depth: 8))
        let leading = try await background.blended(with: foreground, blendingMode: .over, placement: .fill,
                                                  alignment: Graphic3D.Alignment3D(x: .leading))
        let trailing = try await background.blended(with: foreground, blendingMode: .over, placement: .fill,
                                                   alignment: Graphic3D.Alignment3D(x: .trailing))
        let leadingColors = try await leading.voxelColors
        let trailingColors = try await trailing.voxelColors
        #expect(leadingColors[4][4][4].red < 0.2)
        #expect(trailingColors[4][4][4].red > 0.8)
    }

    @Test("Graphic3D: Stacks preserve order, gaps, and perpendicular alignment", arguments: [0, 1, 2])
    func axisStacks(axis: Int) async throws {
        let red = try await Graphic3D.color(.red, resolution: Size3D(width: 2, height: 2, depth: 2))
        let green = try await Graphic3D.color(.green, resolution: Size3D(width: 4, height: 4, depth: 4))
        let blue = try await Graphic3D.color(.blue, resolution: Size3D(width: 2, height: 2, depth: 2))
        let result: Graphic3D
        switch axis {
        case 0: result = try await Graphic3D.hStacked(with: [red, green, blue], yAlignment: .top, zAlignment: .far, spacing: 1)
        case 1: result = try await Graphic3D.vStacked(with: [red, green, blue], xAlignment: .leading, zAlignment: .far, spacing: 1)
        default: result = try await Graphic3D.dStacked(with: [red, green, blue], xAlignment: .leading, yAlignment: .top, spacing: 1)
        }
        #expect(result.resolution == Size3D(width: axis == 0 ? 10 : 4, height: axis == 1 ? 10 : 4, depth: axis == 2 ? 10 : 4))
        let voxels = try await result.voxelColors
        let line = (0..<10).map { index in
            switch axis {
            case 0: voxels[0][3][index]
            case 1: voxels[0][9 - index][0]
            default: voxels[index][3][0]
            }
        }
        #expect(line[0].red > 0.99)
        #expect(line[2].opacity < 0.01)
        #expect(line[3].green > 0.99)
        #expect(line[7].opacity < 0.01)
        #expect(line[8].blue > 0.99)
        #expect(voxels[axis == 2 ? 0 : 3][axis == 1 ? 0 : 3][axis == 0 ? 0 : 3].opacity < 0.01)
    }

    @Test("Graphic3D: Layers preserve precision and apply the selected blend after the first volume")
    func layers() async throws {
        let white = try await Graphic3D.color(.white, resolution: Size3D(width: 4, height: 4, depth: 4), options: .bit16)
        let red = try await Graphic3D.color(.red, resolution: Size3D(width: 2, height: 2, depth: 2), options: .bit16)
        let result = try await Graphic3D.layered(with: [white, red], blendingMode: .multiply,
                                               alignment: Graphic3D.Alignment3D(x: .trailing, y: .bottom, z: .near))
        let voxels = try await result.voxelColors
        #expect(result.bits == white.bits)
        #expect(result.resolution == white.resolution)
        // Multiply also multiplies alpha; samples outside the smaller volume are clear.
        #expect(voxels[0][0][0].opacity < 0.01)
        #expect(voxels[3][0][3].red > 0.99)
        #expect(voxels[3][0][3].green < 0.01)
    }

    @Test("Graphic3D: Empty stacks report an error")
    func emptyStack() async {
        await #expect(throws: Graphic3D.StackError.self) { try await Graphic3D.hStacked(with: []) }
        await #expect(throws: Graphic3D.StackError.self) { try await Graphic3D.vStacked(with: []) }
        await #expect(throws: Graphic3D.StackError.self) { try await Graphic3D.dStacked(with: []) }
        await #expect(throws: Graphic3D.StackError.self) { try await Graphic3D.layered(with: []) }
    }

    // MARK: - Helpers

    private static var alignments: [Graphic3D.Alignment3D] {
        Graphic3D.Alignment3D.X.allCases.flatMap { x in
            Graphic3D.Alignment3D.Y.allCases.flatMap { y in
                Graphic3D.Alignment3D.Z.allCases.map { z in
                    Graphic3D.Alignment3D(x: x, y: y, z: z)
                }
            }
        }
    }
}

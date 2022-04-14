//
//  File.swift
//  
//
//  Created by Anton Heestand on 2022-04-11.
//

import CoreGraphics

public extension Graphic3D {
    
    private struct Average3DUniforms {
        let axis: Int
    }
    
    func average(axis: Axis) async throws -> Graphic {
        
        let resolution: CGSize = CGSize(width: axis == .x ? CGFloat(resolution.z) : CGFloat(resolution.x),
                                        height: axis == .y ? CGFloat(resolution.z) : CGFloat(resolution.y))
        
        return try await Renderer.render(
            name: "Average",
            shaderName: "average",
            graphics: [self],
            uniforms: Average3DUniforms(
                axis: axis.index
            ),
            metadata: Metadata(
                resolution: resolution,
                colorSpace: colorSpace,
                bits: bits
            )
        )
    }
}

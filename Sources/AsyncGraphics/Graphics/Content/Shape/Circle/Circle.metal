//
//  Created by Anton Heestand on 2017-11-17.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#import "../../../../Shaders/Content/shape_coverage_header.metal"

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    bool premultiply;
    bool antiAlias;
    float radius;
    packed_float2 position;
    float edgeRadius;
    packed_float4 foregroundColor;
    packed_float4 edgeColor;
    packed_float4 backgroundColor;
    packed_float2 resolution;
    packed_float2 tileOrigin;
    packed_float2 tileSize;
};

fragment float4 circle(VertexOut out [[stage_in]],
                       const device Uniforms& uniforms [[ buffer(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    u = u * uniforms.tileSize.x + uniforms.tileOrigin.x;
    v = v * uniforms.tileSize.y + uniforms.tileOrigin.y;

    float height = uniforms.resolution.y;
    float2 point = (float2(u, v) - 0.5) * float2(uniforms.resolution)
        - float2(uniforms.position) * height;
    float radius = uniforms.radius * height;
    float lineWidth = max(uniforms.edgeRadius, 0.0) * height;
    float distance = length(point) - radius;

    if (lineWidth > 0.0) {
        float coverage = radius - lineWidth / 2.0 > 0.0
            ? agShapeStrokeCoverage(distance, lineWidth, uniforms.antiAlias)
            : agShapeCoverage(distance - lineWidth / 2.0, uniforms.antiAlias);
        return agShapeColor(coverage, uniforms.edgeColor, uniforms.backgroundColor, uniforms.premultiply);
    }

    float coverage = radius > 0.0 ? agShapeCoverage(distance, uniforms.antiAlias) : 0.0;
    return agShapeColor(coverage, uniforms.foregroundColor, uniforms.backgroundColor, uniforms.premultiply);
}

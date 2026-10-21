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
    packed_float2 size;
    packed_float2 position;
    float cornerRadius;
    float edgeRadius;
    packed_float4 foregroundColor;
    packed_float4 edgeColor;
    packed_float4 backgroundColor;
    packed_float2 resolution;
    packed_float2 tileOrigin;
    packed_float2 tileSize;
};

inline float rectangleDistance(float2 point, float2 halfSize, float cornerRadius) {
    float2 delta = abs(point) - halfSize + cornerRadius;
    return length(max(delta, 0.0)) + min(max(delta.x, delta.y), 0.0) - cornerRadius;
}

fragment float4 rectangle(VertexOut out [[stage_in]],
                          const device Uniforms& uniforms [[ buffer(0) ]]) {
    float2 uv = out.texCoord * float2(uniforms.tileSize) + float2(uniforms.tileOrigin);
    float height = uniforms.resolution.y;
    float2 point = (uv - 0.5) * float2(uniforms.resolution) - float2(uniforms.position) * height;
    float2 halfSize = max(float2(uniforms.size) * height / 2.0, 0.0);
    float cornerRadius = clamp(uniforms.cornerRadius * height, 0.0, min(halfSize.x, halfSize.y));
    float lineWidth = max(uniforms.edgeRadius, 0.0) * height;

    if (lineWidth > 0.0) {
        float halfWidth = lineWidth / 2.0;
        // A sharp rectangle keeps its original mitered stroke corners.
        float outerRadius = cornerRadius > 0.0 ? cornerRadius + halfWidth : 0.0;
        float outerDistance = rectangleDistance(point, halfSize + halfWidth, outerRadius);
        float outerCoverage = agShapeCoverage(outerDistance, uniforms.antiAlias);
        float2 innerSize = halfSize - halfWidth;
        float innerCoverage = 0.0;
        if (innerSize.x > 0.0 && innerSize.y > 0.0) {
            float innerRadius = max(cornerRadius - halfWidth, 0.0);
            float innerDistance = rectangleDistance(point, innerSize, innerRadius);
            innerCoverage = agShapeCoverage(innerDistance, uniforms.antiAlias);
        }
        return agShapeColor(max(outerCoverage - innerCoverage, 0.0),
                            uniforms.edgeColor, uniforms.backgroundColor, uniforms.premultiply);
    }

    float distance = rectangleDistance(point, halfSize, cornerRadius);
    float coverage = halfSize.x > 0.0 && halfSize.y > 0.0
        ? agShapeCoverage(distance, uniforms.antiAlias) : 0.0;
    return agShapeColor(coverage, uniforms.foregroundColor, uniforms.backgroundColor, uniforms.premultiply);
}

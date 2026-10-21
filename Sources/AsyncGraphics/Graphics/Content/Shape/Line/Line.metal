//
//  ContentGeneratorLinePIX.metal
//  PixelKit Shaders
//
//  Created by Anton Heestand on 2017-11-17.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
#include "../../../../Shaders/Content/shape_coverage_header.metal"
using namespace metal;

struct VertexOut{
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms{
    bool premultiply;
    bool antiAlias;
    int cap;
    float lineWidth;
    packed_float2 leadingPoint;
    packed_float2 trailingPoint;
    packed_float4 foregroundColor;
    packed_float4 backgroundColor;
    packed_float2 resolution;
    packed_float2 tileOrigin;
    packed_float2 tileSize;
};

fragment float4 line(VertexOut out [[stage_in]],
                     const device Uniforms& uniforms [[ buffer(0) ]],
                     sampler s [[ sampler(0) ]]) {
    float2 resolution = uniforms.resolution;
    float2 uv = out.texCoord * float2(uniforms.tileSize) + float2(uniforms.tileOrigin);
    float2 point = uv * resolution;
    float2 leading = float2(uniforms.leadingPoint) * resolution.y + resolution / 2.0;
    float2 trailing = float2(uniforms.trailingPoint) * resolution.y + resolution / 2.0;
    float lineWidth = uniforms.lineWidth * resolution.y;
    float2 vector = trailing - leading;
    float segmentLength = length(vector);
    float2 direction = segmentLength > 0.0 ? vector / segmentLength : float2(1.0, 0.0);
    float2 normal = float2(-direction.y, direction.x);
    float2 relative = point - (leading + trailing) / 2.0;
    float2 local = float2(dot(relative, direction), dot(relative, normal));

    float coverage = 0.0;
    if (lineWidth > 0.0) {
        if (uniforms.cap == 1) {
            float projection = clamp(dot(point - leading, direction), 0.0, segmentLength);
            float distance = length(point - leading - direction * projection);
            if (uniforms.antiAlias) {
                // The unsigned distance has a cusp on the centerline. Its
                // derivative can vanish across a pixel pair for thin strokes.
                float antialiasWidth = max(fwidth(local.y), 0.0001);
                coverage = agShapeCoverageWithWidth(distance - lineWidth / 2.0, antialiasWidth)
                    - agShapeCoverageWithWidth(distance + lineWidth / 2.0, antialiasWidth);
            } else {
                coverage = distance < lineWidth / 2.0 ? 1.0 : 0.0;
            }
        } else if (uniforms.cap == 2) {
            float sideCoverage = agShapeStrokeCoverage(local.y, lineWidth, uniforms.antiAlias);
            float capDistance = (abs(local.x) + abs(local.y) - segmentLength / 2.0 - lineWidth / 2.0) / sqrt(2.0);
            coverage = sideCoverage * agShapeCoverage(capDistance, uniforms.antiAlias);
        } else if (segmentLength > 0.0) {
            // Legacy LineCap.square stops at the endpoints, like a butt cap.
            float sideCoverage = agShapeStrokeCoverage(local.y, lineWidth, uniforms.antiAlias);
            float endCoverage = agShapeCoverage(abs(local.x) - segmentLength / 2.0, uniforms.antiAlias);
            coverage = sideCoverage * endCoverage;
        }
    }
    return agShapeColor(coverage, uniforms.foregroundColor, uniforms.backgroundColor, uniforms.premultiply);
}

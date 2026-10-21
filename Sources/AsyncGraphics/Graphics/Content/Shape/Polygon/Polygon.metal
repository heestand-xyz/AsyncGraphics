//
//  Created by Anton Heestand on 2017-11-21.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
#include "../../../../Shaders/Content/shape_coverage_header.metal"
using namespace metal;

struct PolygonVertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct PolygonUniforms {
    float radius;
    packed_float2 position;
    float rotation;
    uint count;
    packed_float4 foregroundColor;
    packed_float4 backgroundColor;
    float cornerRadius;
    bool premultiply;
    bool antiAlias;
    packed_float2 resolution;
    packed_float2 tileOrigin;
    packed_float2 tileSize;
};

fragment float4 polygon(PolygonVertexOut out [[stage_in]],
                        const device PolygonUniforms& uniforms [[buffer(0)]]) {
    float2 uv = out.texCoord * float2(uniforms.tileSize) + float2(uniforms.tileOrigin);
    float2 point = uv * float2(uniforms.resolution) - float2(uniforms.position);
    float4 foreground = uniforms.foregroundColor;
    float4 background = uniforms.backgroundColor;
    if (uniforms.radius <= 0.0 || any(abs(point) > uniforms.radius + 2.0)) {
        return agShapeColor(0.0, foreground, background, uniforms.premultiply);
    }

    float halfSector = M_PI_F / float(uniforms.count);
    float apothem = uniforms.radius * cos(halfSector);
    float rounding = min(uniforms.cornerRadius, apothem);
    float distance;
    if (rounding >= apothem) {
        distance = length(point) - apothem;
    } else {
        // Offset an inset regular polygon by the circular corner radius. The
        // result retains the original straight edges and exact tangent arcs.
        float insetRadius = (apothem - rounding) / cos(halfSector);
        float angle = atan2(-point.x, -point.y) - uniforms.rotation;
        float sector = halfSector * 2.0;
        float foldedAngle = angle - sector * floor(angle / sector) - halfSector;
        float radialDistance = length(point);
        float2 foldedPoint = float2(sin(foldedAngle), cos(foldedAngle)) * radialDistance;
        float2 edgePoint = float2(clamp(foldedPoint.x, -insetRadius * sin(halfSector), insetRadius * sin(halfSector)),
                                 insetRadius * cos(halfSector));
        float signedDistance = length(foldedPoint - edgePoint);
        if (foldedPoint.y < edgePoint.y) signedDistance = -signedDistance;
        distance = signedDistance - rounding;
    }
    return agShapeColor(agShapeCoverage(distance, uniforms.antiAlias),
                        foreground, background, uniforms.premultiply);
}

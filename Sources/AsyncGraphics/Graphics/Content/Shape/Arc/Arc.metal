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
    float angleCenter;
    float angleLength;
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

inline float arcSegmentDistance(float2 point, float2 end) {
    float fraction = clamp(dot(point, end) / max(dot(end, end), 0.000001), 0.0, 1.0);
    return length(point - end * fraction);
}

inline float arcSectorDistance(float2 point, float radius, float halfAngle) {
    float radialDistance = length(point) - radius;
    if (halfAngle >= M_PI_F) {
        return radialDistance;
    }

    float angle = atan2(point.y, point.x);
    float closestAngle = clamp(angle, -halfAngle, halfAngle);
    float2 closestArcPoint = float2(cos(closestAngle), sin(closestAngle)) * radius;
    float2 upperEnd = float2(cos(halfAngle), sin(halfAngle)) * radius;
    float2 lowerEnd = float2(upperEnd.x, -upperEnd.y);
    float boundaryDistance = min(length(point - closestArcPoint),
                                 min(arcSegmentDistance(point, upperEnd), arcSegmentDistance(point, lowerEnd)));
    bool inside = radialDistance < 0.0 && abs(angle) < halfAngle;
    return inside ? -boundaryDistance : boundaryDistance;
}

fragment float4 arc(VertexOut out [[stage_in]],
                    const device Uniforms& uniforms [[ buffer(0) ]]) {
    float2 uv = out.texCoord * float2(uniforms.tileSize) + float2(uniforms.tileOrigin);
    float height = uniforms.resolution.y;
    float2 point = (uv - 0.5) * float2(uniforms.resolution) - float2(uniforms.position) * height;
    float center = uniforms.angleCenter * M_PI_F * 2.0;
    float sine = sin(center);
    float cosine = cos(center);
    point = float2(point.x * cosine + point.y * sine, -point.x * sine + point.y * cosine);
    float halfAngle = min(uniforms.angleLength * M_PI_F, M_PI_F);
    float radius = uniforms.radius * height;
    float lineWidth = max(uniforms.edgeRadius, 0.0) * height;

    if (halfAngle <= 0.0) {
        return agShapeColor(0.0, uniforms.foregroundColor, uniforms.backgroundColor, uniforms.premultiply);
    }

    if (lineWidth > 0.0) {
        float outerRadius = radius + lineWidth / 2.0;
        float innerRadius = radius - lineWidth / 2.0;
        float outerCoverage = outerRadius > 0.0
            ? agShapeCoverage(arcSectorDistance(point, outerRadius, halfAngle), uniforms.antiAlias) : 0.0;
        float innerCoverage = innerRadius > 0.0
            ? agShapeCoverage(arcSectorDistance(point, innerRadius, halfAngle), uniforms.antiAlias) : 0.0;
        return agShapeColor(max(outerCoverage - innerCoverage, 0.0),
                            uniforms.edgeColor, uniforms.backgroundColor, uniforms.premultiply);
    }

    float coverage = radius > 0.0
        ? agShapeCoverage(arcSectorDistance(point, radius, halfAngle), uniforms.antiAlias) : 0.0;
    return agShapeColor(coverage, uniforms.foregroundColor, uniforms.backgroundColor, uniforms.premultiply);
}

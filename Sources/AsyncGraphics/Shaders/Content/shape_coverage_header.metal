#ifndef ASYNCGRAPHICS_SHAPE_COVERAGE_HEADER
#define ASYNCGRAPHICS_SHAPE_COVERAGE_HEADER

#include <metal_stdlib>
using namespace metal;

inline float agShapeCoverageWithWidth(float signedDistance, float antialiasWidth) {
    return clamp(0.5 - signedDistance / antialiasWidth, 0.0, 1.0);
}

// Distances are in output pixels and negative inside the shape. Derivatives keep
// coverage consistent for diagonal edges, tiled renders, and every aspect ratio.
// The one-pixel floor preserves coverage when a tiny shape is symmetric across
// a derivative quad and its sampled distance derivatives cancel out.
inline float agShapeCoverage(float signedDistance, bool antiAlias) {
    if (!antiAlias) {
        return signedDistance < 0.0 ? 1.0 : 0.0;
    }
    float antialiasWidth = max(fwidth(signedDistance), 1.0);
    return agShapeCoverageWithWidth(signedDistance, antialiasWidth);
}

inline float agShapeStrokeCoverage(float signedDistance, float lineWidth, bool antiAlias) {
    if (lineWidth <= 0.0) {
        return 0.0;
    }
    if (!antiAlias) {
        return abs(signedDistance) < lineWidth / 2.0 ? 1.0 : 0.0;
    }
    float antialiasWidth = max(fwidth(signedDistance), 1.0);
    float outer = agShapeCoverageWithWidth(signedDistance - lineWidth / 2.0, antialiasWidth);
    float inner = agShapeCoverageWithWidth(signedDistance + lineWidth / 2.0, antialiasWidth);
    return clamp(outer - inner, 0.0, 1.0);
}

inline float4 agShapeColor(float coverage,
                          float4 foregroundColor,
                          float4 backgroundColor,
                          bool premultiply) {
    coverage = clamp(coverage, 0.0, 1.0);
    float4 foreground = float4(foregroundColor.rgb * foregroundColor.a, foregroundColor.a);
    float4 background = float4(backgroundColor.rgb * backgroundColor.a, backgroundColor.a);
    float4 color = mix(background, foreground, coverage);
    if (!premultiply) {
        // Keep intentionally hidden RGB, including pureTranslucentColor, when
        // there is no alpha to unpremultiply.
        color.rgb = color.a != 0.0
            ? color.rgb / color.a
            : mix(backgroundColor.rgb, foregroundColor.rgb, coverage);
    }
    return color;
}

#endif

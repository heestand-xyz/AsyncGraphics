#include <metal_stdlib>
#include "../../../../Shaders/Content/shape_coverage_header.metal"
using namespace metal;

struct AreaPathVertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct AreaPathUniforms {
    uint segmentCount;
    bool evenOdd;
    bool premultiply;
    bool antiAlias;
    packed_float4 foregroundColor;
    packed_float4 backgroundColor;
    packed_float2 boundsMinimum;
    packed_float2 boundsMaximum;
    packed_float2 resolution;
    packed_float2 tileOrigin;
    packed_float2 tileSize;
};

struct AreaPathSegment {
    packed_float2 leading;
    packed_float2 trailing;
};

inline int areaPathCrossing(float2 point, float2 leading, float2 trailing) {
    if ((leading.y <= point.y && trailing.y > point.y) ||
        (trailing.y <= point.y && leading.y > point.y)) {
        float crossingX = leading.x + (point.y - leading.y) * (trailing.x - leading.x) / (trailing.y - leading.y);
        if (point.x < crossingX) {
            return trailing.y > leading.y ? 1 : -1;
        }
    }
    return 0;
}

inline bool areaPathEdgeOverlaps(float2 leading, float2 trailing, float2 minimum, float2 maximum) {
    return all(max(leading, trailing) >= minimum) && all(min(leading, trailing) <= maximum);
}

inline float areaPathCross(float2 a, float2 b) {
    return a.x * b.y - a.y * b.x;
}

// Find the next height where a clipped edge begins, ends, or changes its order
// relative to another edge. Between these heights the covered width is linear.
inline float areaPathNextHeight(float height, float2 minimum, float2 maximum,
                               const device AreaPathSegment* segments, uint count) {
    float nextHeight = maximum.y;
    for (uint index = 0; index < count; ++index) {
        float2 leading = segments[index].leading;
        float2 trailing = segments[index].trailing;
        if (!areaPathEdgeOverlaps(leading, trailing, minimum, maximum)) continue;
        if (leading.y > height) nextHeight = min(nextHeight, leading.y);
        if (trailing.y > height) nextHeight = min(nextHeight, trailing.y);
        float2 direction = trailing - leading;
        if (direction.x != 0.0) {
            for (uint side = 0; side < 2; ++side) {
                float x = side == 0 ? minimum.x : maximum.x;
                float fraction = (x - leading.x) / direction.x;
                if (fraction > 0.0 && fraction < 1.0) {
                    float y = leading.y + fraction * direction.y;
                    if (y > height) nextHeight = min(nextHeight, y);
                }
            }
        }
        // Only edges overlapping this pixel participate in the pair test.
        // This handles self-intersections and overlapping stroke contours.
        for (uint other = index + 1; other < count; ++other) {
            float2 otherLeading = segments[other].leading;
            float2 otherTrailing = segments[other].trailing;
            if (!areaPathEdgeOverlaps(otherLeading, otherTrailing, minimum, maximum)) continue;
            float2 otherDirection = otherTrailing - otherLeading;
            float denominator = areaPathCross(direction, otherDirection);
            if (denominator == 0.0) continue;
            float2 offset = otherLeading - leading;
            float fraction = areaPathCross(offset, otherDirection) / denominator;
            float otherFraction = areaPathCross(offset, direction) / denominator;
            if (fraction > 0.0 && fraction < 1.0 && otherFraction > 0.0 && otherFraction < 1.0) {
                float2 intersection = leading + fraction * direction;
                if (intersection.x >= minimum.x && intersection.x <= maximum.x && intersection.y > height) {
                    nextHeight = min(nextHeight, intersection.y);
                }
            }
        }
    }
    return nextHeight;
}

inline float areaPathSliceWidth(float height, float minimum, float maximum,
                               const device AreaPathSegment* segments, uint count, bool evenOdd) {
    float width = 0.0;
    float position = minimum;
    while (position < maximum) {
        int winding = 0;
        float nextPosition = maximum;
        for (uint index = 0; index < count; ++index) {
            float2 leading = segments[index].leading;
            float2 trailing = segments[index].trailing;
            if ((leading.y <= height && trailing.y > height) ||
                (trailing.y <= height && leading.y > height)) {
                float crossing = leading.x + (height - leading.y) * (trailing.x - leading.x) / (trailing.y - leading.y);
                if (crossing > position) {
                    winding += trailing.y > leading.y ? 1 : -1;
                    nextPosition = min(nextPosition, crossing);
                }
            }
        }
        if (evenOdd ? (winding % 2 != 0) : winding != 0) width += nextPosition - position;
        position = nextPosition;
    }
    return width;
}

inline float areaPathCoverage(float2 minimum, float2 maximum,
                              const device AreaPathSegment* segments, uint count, bool evenOdd) {
    float area = 0.0;
    float height = minimum.y;
    while (height < maximum.y) {
        float nextHeight = areaPathNextHeight(height, minimum, maximum, segments, count);
        float middle = height + (nextHeight - height) * 0.5;
        area += areaPathSliceWidth(middle, minimum.x, maximum.x, segments, count, evenOdd) * (nextHeight - height);
        height = nextHeight;
    }
    return clamp(area / ((maximum.x - minimum.x) * (maximum.y - minimum.y)), 0.0, 1.0);
}

fragment float4 areaPath(
    AreaPathVertexOut out [[stage_in]],
    const device AreaPathUniforms& uniforms [[buffer(0)]],
    const device AreaPathSegment* segments [[buffer(1)]]
) {
    float2 uv = out.texCoord * float2(uniforms.tileSize) + float2(uniforms.tileOrigin);
    float2 point = uv * float2(uniforms.resolution);
    float2 pixelSize = max(float2(length(dfdx(point)), length(dfdy(point))), float2(0.000001));
    float2 halfPixel = pixelSize * 0.5;
    float4 foreground = uniforms.foregroundColor;
    float4 background = uniforms.backgroundColor;
    if (uniforms.segmentCount == 0 ||
        any(point < float2(uniforms.boundsMinimum) - halfPixel) ||
        any(point > float2(uniforms.boundsMaximum) + halfPixel)) {
        return agShapeColor(0.0, foreground, background, uniforms.premultiply);
    }

    int winding = 0;
    bool nearEdge = false;
    for (uint index = 0; index < uniforms.segmentCount; ++index) {
        float2 leading = segments[index].leading;
        float2 trailing = segments[index].trailing;
        winding += areaPathCrossing(point, leading, trailing);
        if (!nearEdge && uniforms.antiAlias &&
            areaPathEdgeOverlaps(leading, trailing, point - halfPixel, point + halfPixel)) {
            float2 direction = trailing - leading;
            float lengthSquared = dot(direction, direction);
            float fraction = lengthSquared > 0.0 ? clamp(dot(point - leading, direction) / lengthSquared, 0.0, 1.0) : 0.0;
            float2 distance = point - (leading + fraction * direction);
            nearEdge = dot(distance, distance) <= dot(halfPixel, halfPixel);
        }
    }
    bool inside = uniforms.evenOdd ? (winding % 2 != 0) : winding != 0;
    float coverage = inside ? 1.0 : 0.0;
    if (nearEdge) {
        // Exact box coverage of the flattened contours avoids sample-grid loss
        // of arbitrarily thin strokes while retaining winding/union semantics.
        coverage = areaPathCoverage(point - halfPixel, point + halfPixel,
                                    segments, uniforms.segmentCount, uniforms.evenOdd);
    }
    return agShapeColor(coverage, foreground, background, uniforms.premultiply);
}

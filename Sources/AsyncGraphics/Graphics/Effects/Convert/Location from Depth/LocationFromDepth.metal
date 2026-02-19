//
//  LocationFromDepth.metal
//  AsyncGraphics
//
//  Created by Anton Heestand with AI on 2026-02-19.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    float4x4 inverseViewProjectionMatrix;
};

fragment float4 locationFromDepth(
    VertexOut out [[stage_in]],
    texture2d<float> depthTexture [[texture(0)]],
    const device Uniforms& uniforms [[buffer(0)]],
    sampler sampler [[sampler(0)]]
) {
    float2 uv = out.texCoord;
    float depth = depthTexture.sample(sampler, uv).r;

    float2 ndc = float2(
        uv.x * 2.0 - 1.0,
        1.0 - uv.y * 2.0
    );
    float4 clipPosition = float4(ndc.x, ndc.y, depth, 1.0);

    float4 worldPositionHomogeneous = uniforms.inverseViewProjectionMatrix * clipPosition;

    if (!isfinite(worldPositionHomogeneous.x)
        || !isfinite(worldPositionHomogeneous.y)
        || !isfinite(worldPositionHomogeneous.z)
        || !isfinite(worldPositionHomogeneous.w)) {
        return float4(0.0);
    }

    if (fabs(worldPositionHomogeneous.w) < 0.0000001) {
        return float4(0.0);
    }

    float3 worldPosition = worldPositionHomogeneous.xyz / worldPositionHomogeneous.w;

    if (!isfinite(worldPosition.x)
        || !isfinite(worldPosition.y)
        || !isfinite(worldPosition.z)) {
        return float4(0.0);
    }

    return float4(worldPosition, 1.0);
}

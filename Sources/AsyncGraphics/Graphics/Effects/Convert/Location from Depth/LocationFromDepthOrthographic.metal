//
//  LocationFromDepthOrthographic.metal
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
    float4x4 cameraWorldMatrix;
    float near;
    float far;
    float halfWidth;
    float halfHeight;
};

fragment float4 locationFromDepthOrthographic(
    VertexOut out [[stage_in]],
    texture2d<float> depthTexture [[texture(0)]],
    const device Uniforms& uniforms [[buffer(0)]],
    sampler sampler [[sampler(0)]]
) {
    float2 uv = out.texCoord;
    float depth = depthTexture.sample(sampler, uv).r;

    if (!isfinite(depth)) {
        return float4(0.0);
    }

    float ndcX = uv.x * 2.0 - 1.0;
    float ndcY = 1.0 - uv.y * 2.0;

    float viewX = ndcX * uniforms.halfWidth;
    float viewY = ndcY * uniforms.halfHeight;
    float viewZ = -(uniforms.near + depth * (uniforms.far - uniforms.near));

    float4 viewPosition = float4(viewX, viewY, viewZ, 1.0);
    float4 worldPosition = uniforms.cameraWorldMatrix * viewPosition;

    if (!isfinite(worldPosition.x)
        || !isfinite(worldPosition.y)
        || !isfinite(worldPosition.z)
        || !isfinite(worldPosition.w)) {
        return float4(0.0);
    }

    if (fabs(worldPosition.w) < 0.0000001) {
        return float4(0.0);
    }

    float3 worldXYZ = worldPosition.xyz / worldPosition.w;
    if (!isfinite(worldXYZ.x)
        || !isfinite(worldXYZ.y)
        || !isfinite(worldXYZ.z)) {
        return float4(0.0);
    }

    return float4(worldXYZ, 1.0);
}

//
//  LocationFromDepthWithCurvature.metal
//  AsyncGraphics
//
//  Created by Anton Heestand with AI on 2026-03-19.
//

#include <metal_stdlib>
using namespace metal;

#include "LocationFromDepthCameraProjection.metalh"

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    LocationFromDepthCameraUniforms camera;
};

fragment float4 locationFromDepthWithCurvature(
    VertexOut out [[stage_in]],
    texture2d<float> depthTexture [[texture(0)]],
    const device Uniforms& uniforms [[buffer(0)]],
    sampler sampler [[sampler(0)]]
) {
    float2 uv = out.texCoord;
    float depth = depthTexture.sample(sampler, uv).r;

    bool isValid = false;
    float4 worldPosition = locationFromDepthWorldPosition(uv, depth, uniforms.camera, isValid);
    if (!isValid) {
        return float4(0.0f);
    }

    if (!isfinite(worldPosition.x)
        || !isfinite(worldPosition.y)
        || !isfinite(worldPosition.z)
        || !isfinite(worldPosition.w)) {
        return float4(0.0f);
    }

    return worldPosition;
}

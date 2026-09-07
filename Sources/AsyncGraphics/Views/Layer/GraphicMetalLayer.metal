//
//  GraphicMetalLayer.metal
//  AsyncGraphics
//

#include <metal_stdlib>
using namespace metal;

struct GraphicLayerVertex {
    float4 position [[position]];
    float2 uv;
};

vertex GraphicLayerVertex graphicLayerVertex(uint id [[vertex_id]]) {
    // One oversized triangle covers the drawable without a vertex buffer.
    float2 uv = float2((id << 1) & 2, id & 2);
    return { float4(uv.x * 2.0 - 1.0, 1.0 - uv.y * 2.0, 0.0, 1.0), uv };
}

fragment float4 graphicLayerFragment(
    GraphicLayerVertex in [[stage_in]],
    texture2d<float> texture [[texture(0)]],
    sampler textureSampler [[sampler(0)]]
) {
    return texture.sample(textureSampler, in.uv);
}

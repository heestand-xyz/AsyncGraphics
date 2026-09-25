//
//  SamplePlane3D.metal
//  AsyncGraphics
//
//  Created by Anton Heestand with AI on 2026-09-25.
//

#include <metal_stdlib>
using namespace metal;

struct SamplePlaneVertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct SamplePlane3DUniforms {
    uint axis;
    uint index;
};

fragment float4 samplePlane3d(SamplePlaneVertexOut out [[stage_in]],
                             constant SamplePlane3DUniforms& uniforms [[buffer(0)]],
                             texture3d<float, access::read> texture [[texture(0)]]) {
    uint width = uniforms.axis == 0 ? texture.get_depth() : texture.get_width();
    uint height = uniforms.axis == 1 ? texture.get_depth() : texture.get_height();
    uint2 pixel = min(uint2(out.texCoord * float2(width, height)), uint2(width - 1, height - 1));
    uint3 position;
    switch (uniforms.axis) {
        case 0: position = uint3(uniforms.index, pixel.y, pixel.x); break;
        case 1: position = uint3(pixel.x, uniforms.index, pixel.y); break;
        default: position = uint3(pixel.x, pixel.y, uniforms.index); break;
    }
    return texture.read(position);
}

//
//  Slice.metal
//  AsyncGraphics
//
//  Created by Anton Heestand with AI on 2026-05-10.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    int axis;
    float location;
};

fragment float4 slice3d(VertexOut out [[stage_in]],
                        const device Uniforms& uniforms [[ buffer(0) ]],
                        texture3d<float> texture [[ texture(0) ]],
                        sampler sampler [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    
    int res = 0;
    switch (uniforms.axis) {
        case 0: res = texture.get_width(); break;
        case 1: res = texture.get_height(); break;
        case 2: res = texture.get_depth(); break;
    }
    
    float sample = (uniforms.location + 0.5) / float(res);
    
    float3 crd = 0.0;
    switch (uniforms.axis) {
        case 0: crd = float3(sample, v, u); break;
        case 1: crd = float3(u, sample, v); break;
        case 2: crd = float3(u, v, sample); break;
    }
    
    return texture.sample(sampler, crd);
}

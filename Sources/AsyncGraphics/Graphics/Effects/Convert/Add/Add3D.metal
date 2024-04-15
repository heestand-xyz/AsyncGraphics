//
//  EffectSingleAveragePIX.metal
//  VoxelKitShaders
//
//  Created by Anton Heestand on 2019-10-02.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    int axis;
    float brightness;
};

fragment float4 add3d(VertexOut out [[stage_in]],
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
    
    float4 color = 0.0;
    
    for (int i = 0; i < res; ++i) {
        
        float fraction = (float(i) + 0.5) / float(res);
        
        float3 crd = 0.0;
        switch (uniforms.axis) {
            case 0: crd = float3(fraction, u, v); break;
            case 1: crd = float3(u, fraction, v); break;
            case 2: crd = float3(u, v, fraction); break;
        }
        
        color += texture.sample(sampler, crd);
    }
    
    color *= uniforms.brightness;
    
    return color;
}


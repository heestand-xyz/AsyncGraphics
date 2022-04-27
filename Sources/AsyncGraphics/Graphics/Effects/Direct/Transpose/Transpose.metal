//
//  Created by Anton Heestand on 2017-11-28.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;


struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    uint flip;
    uint flop;
};

fragment float4 transpose(VertexOut out [[stage_in]],
                          texture2d<float> texture [[ texture(0) ]],
                          const device Uniforms& uniforms [[ buffer(0) ]],
                          sampler sampler [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    
    if (uniforms.flip == 1 || uniforms.flip == 3) {
        u = 1.0 - u;
    }
    if (uniforms.flip == 2 || uniforms.flip == 3) {
        v = 1.0 - v;
    }
    
    float2 uv = float2(u, v);
    
    if (uniforms.flop == 1) {
        uv = float2(1.0 - v, u);
    } else if (uniforms.flop == 2) {
        uv = float2(v, 1.0 - u);
    }
    
    float4 c = texture.sample(sampler, uv);
    
    return c;
}

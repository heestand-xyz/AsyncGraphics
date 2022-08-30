//
//  Created by Anton Heestand on 2017-11-30.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    float fraction;
};

fragment float4 threshold(VertexOut out [[stage_in]],
                          texture2d<float> texture [[ texture(0) ]],
                          const device Uniforms& uniforms [[ buffer(0) ]],
                          sampler sampler [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    float4 inputColor = texture.sample(sampler, uv);
    float monochrome = (inputColor.r + inputColor.g + inputColor.b) / 3;
    
    float value = 0.0;
    if (monochrome > uniforms.fraction) {
        value = 1.0;
    }
    
    return float4(float3(value), 1.0);
}

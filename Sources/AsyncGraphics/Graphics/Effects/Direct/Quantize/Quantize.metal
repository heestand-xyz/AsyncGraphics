//
//  Created by Anton Heestand on 2017-11-26.
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

fragment float4 quantize(VertexOut out [[stage_in]],
                         texture2d<float> texture [[ texture(0) ]],
                         const device Uniforms& uniforms [[ buffer(0) ]],
                         sampler sampler [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    float4 inputColor = texture.sample(sampler, uv);
    
    float fraction = uniforms.fraction;
    
    float low = 1.0 / 256;
    if (fraction < low) {
        fraction = low;
    }
    float4 quantizedColor = floor(inputColor / fraction) * fraction;
    
    float4 color = float4(quantizedColor.rgb, inputColor.a);
    
    return color;
}

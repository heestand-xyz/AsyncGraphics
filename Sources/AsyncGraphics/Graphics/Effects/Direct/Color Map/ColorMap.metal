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
    packed_float4 backgroundColor;
    packed_float4 foregroundColor;
};

fragment float4 colorMap(VertexOut out [[stage_in]],
                         texture2d<float> texture [[ texture(0) ]],
                         const device Uniforms& uniforms [[ buffer(0) ]],
                         sampler sampler [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    float4 color = texture.sample(sampler, uv);
    float monochrome = (color.r + color.g + color.b) / 3;
    
    float4 backgroundColor = uniforms.backgroundColor;
    float4 foregroundColor = uniforms.foregroundColor;
    
    return mix(backgroundColor, foregroundColor, monochrome);
}

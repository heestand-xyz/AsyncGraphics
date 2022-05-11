//
//  Created by Anton Heestand on 2017-12-06.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    packed_float4 red;
    packed_float4 green;
    packed_float4 blue;
    packed_float4 alpha;
};

fragment float4 channelMix(VertexOut out [[stage_in]],
                           texture2d<float> texture [[ texture(0) ]],
                           const device Uniforms& uniforms [[ buffer(0) ]],
                           sampler sampler [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    float4 color = texture.sample(sampler, uv);
    
    float4 red = uniforms.red;
    float4 green = uniforms.green;
    float4 blue = uniforms.blue;
    float4 alpha = uniforms.alpha;
    
    color = float4(color.r * red.r + color.g * red.g + color.b * red.b + color.a * red.a,
                   color.r * green.r + color.g * green.g + color.b * green.b + color.a * green.a,
                   color.r * blue.r + color.g * blue.g + color.b * blue.b + color.a * blue.a,
                   color.r * alpha.r + color.g * alpha.g + color.b * alpha.b + color.a * alpha.a);
    
    return color;
}

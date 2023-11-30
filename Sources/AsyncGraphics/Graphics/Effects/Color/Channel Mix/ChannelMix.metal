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
    packed_float4 white;
    packed_float4 mono;
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
    float4 white = uniforms.white;
    float4 mono = uniforms.mono;
    
    float monochrome = (color.r + color.g + color.b) / 3;
    
    color = float4(white.r ? 1.0 : mono.r ? monochrome : color.r * red.r + color.g * red.g + color.b * red.b + color.a * red.a,
                   white.g ? 1.0 : mono.g ? monochrome : color.r * green.r + color.g * green.g + color.b * green.b + color.a * green.a,
                   white.b ? 1.0 : mono.b ? monochrome : color.r * blue.r + color.g * blue.g + color.b * blue.b + color.a * blue.a,
                   white.a ? 1.0 : mono.a ? monochrome : color.r * alpha.r + color.g * alpha.g + color.b * alpha.b + color.a * alpha.a);
    
    return color;
}

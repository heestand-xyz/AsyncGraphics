//
//  EffectSingleCropPIX.metal
//  PixelKitShaders
//
//  Created by Anton Heestand on 2017-11-30.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;


struct VertexOut{
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    packed_float2 origin;
    packed_float2 size;
};

fragment float4 crop(VertexOut out [[stage_in]],
                     texture2d<float> texture [[ texture(0) ]],
                     const device Uniforms& uniforms [[ buffer(0) ]],
                     sampler sampler [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    
    u *= uniforms.size.x;
    u += uniforms.origin.x;
    v *= uniforms.size.y;
    v += uniforms.origin.y;
    
    float2 uv = float2(u, v);
    
    float4 color = texture.sample(sampler, uv);
    
    return color;
}

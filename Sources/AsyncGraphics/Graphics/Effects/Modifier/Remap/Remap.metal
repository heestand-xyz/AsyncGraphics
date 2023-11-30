//
//  EffectMergerRemapPIX.metal
//  PixelKitShaders
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
    bool thing;
};

fragment float4 remap(VertexOut out [[stage_in]],
                      texture2d<float> leadingTexture [[ texture(0) ]],
                      texture2d<float> trailingTexture [[ texture(1) ]],
                      sampler sampler [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    float4 mapColor = leadingTexture.sample(sampler, uv);

    float2 uvMap = float2(mapColor.r, mapColor.g);
    
    float4 color = trailingTexture.sample(sampler, uvMap) * mapColor.a;
    
    return color;
}

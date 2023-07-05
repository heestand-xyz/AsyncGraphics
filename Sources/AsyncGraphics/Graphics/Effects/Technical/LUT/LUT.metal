//
//  Created by Anton Heestand on 2023-07-05.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    int count;
};

fragment float4 lut(VertexOut out [[stage_in]],
                    texture2d<float> leadingTexture [[ texture(0) ]],
                    texture2d<float> trailingTexture [[ texture(1) ]],
                    const device Uniforms& uniforms [[ buffer(0) ]],
                    sampler sampler [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    float4 sourceColor = leadingTexture.sample(sampler, uv);
    
    int count = uniforms.count;

    float3 rgb = sourceColor.rgb;
    
//    float2 uvOrigin = float2(int2(rgb * count)) / count;
//    float2 uvFraction = (uv - uvOrigin) * count;
//
//    float2 uiTopLeft = uvOrigin;
//    float3 rgbTopLeft = trailingTexture.sample(sampler, uvTopLeft);
    
    return sourceColor;
}



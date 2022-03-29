//
//  ImageBlending.metal
//  Metal Image Blending
//
//  Created by Anton Heestand on 2021-09-18.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

fragment float4 imageBlending(VertexOut vertexOut [[stage_in]],
                              texture2d<float> textureA [[ texture(0) ]],
                              texture2d<float> textureB [[ texture(1) ]],
                              sampler sampler [[ sampler(0) ]]) {
    
    float u = vertexOut.texCoord[0];
    float v = vertexOut.texCoord[1];
    float2 uv = float2(u, v);
    
    float4 colorA = textureA.sample(sampler, uv);
    float4 colorB = textureB.sample(sampler, uv);

    float4 blend = colorA + colorB;
    
    return blend;
}


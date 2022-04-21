//
//  Created by Anton Heestand on 2021-09-18.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

fragment float4 bits(VertexOut vertexOut [[stage_in]],
                     texture2d<float> texture [[ texture(0) ]],
                     sampler sampler [[ sampler(0) ]]) {
    
    float u = vertexOut.texCoord[0];
    float v = vertexOut.texCoord[1];
    float2 uv = float2(u, v);
    
    float4 color = texture.sample(sampler, uv);
    
    return color;
}


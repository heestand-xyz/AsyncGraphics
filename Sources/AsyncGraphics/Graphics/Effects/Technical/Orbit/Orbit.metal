//
//  Created by Anton Heestand on 2023-11-23.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

fragment float4 orbit(VertexOut vertexOut [[stage_in]],
                      texture3d<float, access::sample> texture [[ texture(0) ]],
                      sampler sampler [[ sampler(0) ]]) {
    
    float u = vertexOut.texCoord[0];
    float v = vertexOut.texCoord[1];
    float2 uv = float2(u, v);
    
    float3 uvw = float3(u, v, 0.5);
    
    float4 color = texture.sample(sampler, uvw);
    
    return color;
}

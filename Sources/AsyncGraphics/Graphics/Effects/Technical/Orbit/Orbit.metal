//
//  Created by Anton Heestand on 2023-11-23.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut3D {
    float4 position [[position]];
    float3 texCoord;
};

fragment float4 orbit(VertexOut3D vertexOut [[stage_in]],
                      texture3d<float, access::sample> texture [[ texture(0) ]],
                      sampler sampler [[ sampler(0) ]]) {
    
    float u = vertexOut.texCoord[0];
    float v = vertexOut.texCoord[1];
    float w = vertexOut.texCoord[2];
    float3 uvw = float3(u, v, w);
    
    float4 color = texture.sample(sampler, uvw);
    
    return color;
}

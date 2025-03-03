//
//  Created by Anton Heestand on 2020-06-01.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

fragment float4 lumaSample(VertexOut out [[stage_in]],
                           texture2d<float> sampleTexture [[ texture(0) ]],
                           texture3d<float, access::sample> sourceTexture [[ texture(1) ]],
                           sampler sampler [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    float sample = sampleTexture.sample(sampler, uv).r;
    
    float3 uvw = float3(u, v, sample);
    float4 color = sourceTexture.sample(sampler, uvw);
   
    return color;
}

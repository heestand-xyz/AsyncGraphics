//
//  Created by Anton Heestand on 2019-10-02.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

fragment float4 downSample(VertexOut out [[stage_in]],
                           texture2d_ms<float> texture [[ texture(0) ]],
                           sampler sampler [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    
    float4 color = 0.0;
    
    uint sampleCount = texture.get_num_samples();
    
    uint2 pixel = uint2(u * texture.get_width(), v * texture.get_height());
    
    for(uint index = 0; index < sampleCount; index++) {
        float4 sample = texture.read(pixel, index);
        color += sample;
    }
    color /= sampleCount;
    
    return color;
}


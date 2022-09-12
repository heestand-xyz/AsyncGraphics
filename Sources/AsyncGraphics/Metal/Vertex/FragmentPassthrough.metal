//
//  Created by Anton Heestand on 2018-09-22.
//  Copyright © 2018 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

fragment float4 fragmentPassthrough(VertexOut out [[stage_in]],
                                    texture2d<float>  texture [[ texture(0) ]],
                                    sampler sampler [[ sampler(0) ]]) {
    
    float2 uv = out.texCoord;
    
    float4 color = texture.sample(sampler, uv);
    
    return color;
}

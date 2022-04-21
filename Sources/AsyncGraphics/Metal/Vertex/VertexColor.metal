//
//  Created by Anton Heestand on 2018-09-22.
//  Copyright © 2018 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
    float4 color;
};

struct Uniforms {
    packed_float4 color;
};

fragment float4 vertexColor(VertexOut out [[stage_in]],
                            const device Uniforms& uniforms [[ buffer(0) ]]) {
    
    return float4(uniforms.color * out.color);
}


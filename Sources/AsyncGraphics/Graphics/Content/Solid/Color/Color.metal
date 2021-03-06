//
//  Created by Anton Heestand on 2022-04-04.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    packed_float4 color;
};

fragment float4 color(VertexOut out [[stage_in]],
                      const device Uniforms& uniforms [[ buffer(0) ]]) {

    float4 color = uniforms.color;
    
    return color;
}

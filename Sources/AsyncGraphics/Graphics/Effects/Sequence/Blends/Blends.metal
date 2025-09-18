//
//  Created by Anton Heestand on 2017-11-10.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#import "../../../../Shaders/Effects/blends_header.metal"

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    int mode;
};

fragment float4 blends(VertexOut out [[stage_in]],
                       texture2d_array<float> textures [[ texture(0) ]],
                       const device Uniforms& uniforms [[ buffer(0) ]],
                       sampler s [[ sampler(0) ]]) {
    float2 uv = out.texCoord;
    float4 color = blends(uniforms.mode, uv, textures, s);
    return color;
}

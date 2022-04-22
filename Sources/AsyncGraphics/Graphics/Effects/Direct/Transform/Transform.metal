//
//  Created by Anton Heestand on 2017-11-17.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    packed_float2 translation;
    float rotation;
    float scale;
    packed_float2 size;
};

fragment float4 transform(VertexOut out [[stage_in]],
                          texture2d<float> texture [[ texture(0) ]],
                          const device Uniforms& uniforms [[ buffer(0) ]],
                          sampler sampler [[ sampler(0) ]]) {
    
    float pi = M_PI_F;
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    
    uint width = texture.get_width();
    uint height = texture.get_height();
    float aspectRatio = float(width) / float(height);
    
    float2 size = float2(uniforms.size.x * uniforms.scale,
                         uniforms.size.y * uniforms.scale);
    
    float angle = atan2(v - 0.5 - uniforms.translation.y,
                        (u - 0.5) * aspectRatio - uniforms.translation.x)
                    + (-uniforms.rotation * pi * 2);
    float radius = sqrt(pow((u - 0.5) * aspectRatio - uniforms.translation.x, 2)
                        + pow(v - 0.5 - uniforms.translation.y, 2));
    float2 uv = float2((cos(angle) / aspectRatio) * radius,
                        sin(angle) * radius) / size + 0.5;
    
    float4 color = texture.sample(sampler, uv);
    
    return color;
}

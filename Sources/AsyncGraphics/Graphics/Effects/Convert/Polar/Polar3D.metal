//
//  Created by Anton Heestand on 2017-11-21.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    float radius;
};

fragment float4 polar3d(VertexOut out [[stage_in]],
                        texture3d<float> texture [[ texture(0) ]],
                        const device Uniforms& uniforms [[ buffer(0) ]],
                        sampler sampler [[ sampler(0) ]]) {

    float pi = M_PI_F;
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    
    float theta = u * 2.0 * pi;
    float phi = v * pi;

    float x = uniforms.radius * sin(phi) * cos(theta);
    float y = uniforms.radius * sin(phi) * sin(theta);
    float z = uniforms.radius * cos(phi);
    float3 coordinate = float3(x / 2 + 0.5, y / 2 + 0.5, z / 2 + 0.5);
    
    float4 color = texture.sample(sampler, coordinate);
        
    return color;
}

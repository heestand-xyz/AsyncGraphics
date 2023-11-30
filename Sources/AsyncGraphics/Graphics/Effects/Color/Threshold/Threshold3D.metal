//
//  Created by Anton Heestand on 2017-11-21.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct Uniforms {
    float fraction;
    packed_float4 foregroundColor;
    packed_float4 backgroundColor;
};

kernel void threshold3d(const device Uniforms& uniforms [[ buffer(0) ]],
                        texture3d<float, access::write>  targetTexture [[ texture(0) ]],
                        texture3d<float, access::sample> texture [[ texture(1) ]],
                        uint3 pos [[ thread_position_in_grid ]],
                        sampler sampler [[ sampler(0) ]]) {
    
    uint width = targetTexture.get_width();
    uint height = targetTexture.get_height();
    uint depth = targetTexture.get_depth();
    
    if (pos.x >= width || pos.y >= height || pos.z >= depth) {
        return;
    }
    
    float u = float(pos.x + 0.5) / float(width);
    float v = float(pos.y + 0.5) / float(height);
    float w = float(pos.z + 0.5) / float(depth);
    float3 uvw = float3(u, v, w);
    
    float4 color = texture.sample(sampler, uvw);
    float monochrome = (color.r + color.g + color.b) / 3;
    
    float value = 0.0;
    if (monochrome > uniforms.fraction) {
        value = 1.0;
    }
    
    float4 targetColor = mix(uniforms.backgroundColor, uniforms.foregroundColor, value);
    targetTexture.write(targetColor, pos);
}



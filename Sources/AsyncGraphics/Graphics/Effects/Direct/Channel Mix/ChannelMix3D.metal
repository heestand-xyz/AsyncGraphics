//
//  Created by Anton Heestand on 2023-11-18.
//  Copyright © 2023 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct Uniforms {
    packed_float4 red;
    packed_float4 green;
    packed_float4 blue;
    packed_float4 alpha;
    packed_float4 white;
    packed_float4 mono;
};

kernel void channelMix3d(const device Uniforms& uniforms [[ buffer(0) ]],
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
    
    float4 red = uniforms.red;
    float4 green = uniforms.green;
    float4 blue = uniforms.blue;
    float4 alpha = uniforms.alpha;
    float4 white = uniforms.white;
    float4 mono = uniforms.mono;
    
    float monochrome = (color.r + color.g + color.b) / 3;
    
    color = float4(white.r ? 1.0 : mono.r ? monochrome : color.r * red.r + color.g * red.g + color.b * red.b + color.a * red.a,
                   white.g ? 1.0 : mono.g ? monochrome : color.r * green.r + color.g * green.g + color.b * green.b + color.a * green.a,
                   white.b ? 1.0 : mono.b ? monochrome : color.r * blue.r + color.g * blue.g + color.b * blue.b + color.a * blue.a,
                   white.a ? 1.0 : mono.a ? monochrome : color.r * alpha.r + color.g * alpha.g + color.b * alpha.b + color.a * alpha.a);
    
    targetTexture.write(color, pos);
}

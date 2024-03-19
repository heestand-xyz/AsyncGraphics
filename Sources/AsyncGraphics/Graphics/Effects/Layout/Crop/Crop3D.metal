//
//  Crop3D.metal
//  AsyncGraphics
//
//  Created by Anton Heestand on 2024-03-19.
//  Copyright © 2024 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct Uniforms {
    packed_float3 origin;
    packed_float3 size;
};

kernel void crop3d(const device Uniforms& uniforms [[ buffer(0) ]],
                   texture3d<float, access::write> targetTexture [[ texture(0) ]],
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
    
    u *= uniforms.size.x;
    u += uniforms.origin.x;
    v *= uniforms.size.y;
    v += uniforms.origin.y;
    w *= uniforms.size.z;
    w += uniforms.origin.z;
    
    float3 uvw = float3(u, v, w);
    
    float4 color = texture.sample(sampler, uvw);
    
    targetTexture.write(color, pos);
}

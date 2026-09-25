//
//  Created by Anton Heestand on 2022-04-22.
//  Copyright © 2022 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct Construct3DUniforms {
    uint axis;
};

kernel void construct3d(texture3d<float, access::write> targetTexture [[ texture(0) ]],
                        texture2d_array<float> textures [[ texture(1) ]],
                        constant Construct3DUniforms& uniforms [[ buffer(0) ]],
                        uint3 pos [[ thread_position_in_grid ]],
                        sampler sampler [[ sampler(0) ]]) {
            
    uint width = targetTexture.get_width();
    uint height = targetTexture.get_height();
    uint depth = targetTexture.get_depth();
    
    if (pos.x >= width || pos.y >= height || pos.z >= depth) {
        return;
    }
    
    uint count = textures.get_array_size();
    
    uint length = uniforms.axis == 0 ? width : uniforms.axis == 1 ? height : depth;
    if (length != count) {
        return;
    }
    
    float u = uniforms.axis == 0 ? float(pos.z + 0.5) / float(depth) : float(pos.x + 0.5) / float(width);
    float v = uniforms.axis == 1 ? float(pos.z + 0.5) / float(depth) : float(pos.y + 0.5) / float(height);
    float2 uv = float2(u, v);
    
    uint index = uniforms.axis == 0 ? pos.x : uniforms.axis == 1 ? pos.y : pos.z;
    float4 color = textures.sample(sampler, uv, index);
    
    targetTexture.write(color, pos);
}


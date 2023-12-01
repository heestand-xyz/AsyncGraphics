//
//  Created by Anton Heestand on 2017-11-26.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct Uniforms {
    float fraction;
};

kernel void quantize3d(uint3 pos [[ thread_position_in_grid ]],
                       const device Uniforms& uniforms [[ buffer(0) ]],
                       texture3d<float, access::write>  targetTexture [[ texture(0) ]],
                       texture3d<float, access::sample> texture [[ texture(1) ]],
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
    
    float4 inputColor = texture.sample(sampler, uvw);
    
    float fraction = uniforms.fraction;
    
    float low = 1.0 / 256;
    if (fraction < low) {
        fraction = low;
    }
    float4 quantizedColor = floor(inputColor / fraction) * fraction;
    
    float4 color = float4(quantizedColor.rgb, inputColor.a);
    
    targetTexture.write(color, pos);
}

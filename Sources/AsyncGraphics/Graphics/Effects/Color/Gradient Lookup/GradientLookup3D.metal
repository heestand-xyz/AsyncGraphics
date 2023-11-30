//
//  Created by Anton Heestand on 2017-11-14.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#include "../../../../Shaders/Content/gradient_header.metal"

struct Uniforms {
    float gamma;
};

kernel void gradientLookup3d(const device Uniforms& uniforms [[ buffer(0) ]],
                             texture3d<float, access::write>  targetTexture [[ texture(0) ]],
                             texture3d<float, access::sample> texture [[ texture(1) ]],
                             const device array<ColorStopArray, ARRMAX>& colorStops [[ buffer(1) ]],
                             const device array<bool, ARRMAX>& actives [[ buffer(2) ]],
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
    float fraction = (color.r + color.g + color.b) / 3;
    
    fraction = pow(fraction, 1 / max(0.000001, uniforms.gamma));
    
    float4 sampleColor = gradient(fraction, colorStops, actives);
    
    targetTexture.write(sampleColor, pos);
}

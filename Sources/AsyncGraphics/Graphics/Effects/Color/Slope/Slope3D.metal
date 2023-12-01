//
//  Created by Anton Heestand on 2017-11-17.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;


struct VertexOut{
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    float amplitude;
    packed_float4 origin;
};

kernel void slope3d(uint3 pos [[ thread_position_in_grid ]],
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
    float3 uvwX = float3(u + (1.0 / float(width)), v, w);
    float3 uvwY = float3(u, v + (1.0 / float(height)), w);
    float3 uvwZ = float3(u, v, w + (1.0 / float(depth)));
    
    float4 grey = float4(0.5, 0.5, 0.5, 1.0);
    if (uvwX.x > 1.0 || uvwY.y > 1.0 || uvwZ.z > 1.0) {
        targetTexture.write(grey, pos);
        return;
    }
    
    float4 c = texture.sample(sampler, uvw);
    float4 cu = texture.sample(sampler, uvwX);
    float4 cv = texture.sample(sampler, uvwY);
    float4 cw = texture.sample(sampler, uvwZ);
    float c_avg = (c.r + c.g + c.b) / 3.0;
    float cu_avg = (cu.r + cu.g + cu.b) / 3.0;
    float cv_avg = (cv.r + cv.g + cv.b) / 3.0;
    float cw_avg = (cw.r + cw.g + cw.b) / 3.0;
    
    float slope_u = uniforms.origin.x + (c_avg - cu_avg) * uniforms.amplitude * 0.5;
    float slope_v = uniforms.origin.y + (c_avg - cv_avg) * uniforms.amplitude * 0.5;
    float slope_w = uniforms.origin.z + (c_avg - cw_avg) * uniforms.amplitude * 0.5;
    
    float4 color = float4(slope_u, slope_v, slope_w, 1.0);
    
    targetTexture.write(color, pos);
}

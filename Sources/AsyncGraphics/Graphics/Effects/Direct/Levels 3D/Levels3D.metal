//
//  Created by Anton Heestand on 2022-04-22.
//  Copyright © 2022 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct Uniforms {
    float brightness;
    float darkness;
    float contrast;
    float gamma;
    bool invert;
    bool smooth;
    float opacity;
    float offset;
};

kernel void levels3d(const device Uniforms& uniforms [[ buffer(0) ]],
                     texture3d<float, access::write>  targetTexture [[ texture(0) ]],
                     texture3d<float, access::sample> texture [[ texture(1) ]],
                     uint3 pos [[ thread_position_in_grid ]],
                     sampler sampler [[ sampler(0) ]]) {
    
    float pi = M_PI_F;
    
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
    
    float alpha = color.a * uniforms.opacity;
    
    color *= 1 / (1.0 - uniforms.darkness);
    color -= 1.0 / (1.0 - uniforms.darkness) - 1;
    
    color *= uniforms.brightness;
    
    color -= 0.5;
    color *= 1.0 + uniforms.contrast;
    color += 0.5;
    
    color = pow(color, 1 / max(0.001, uniforms.gamma));
    
    if (uniforms.invert) {
        color = 1.0 - color;
    }
    
    if (uniforms.smooth) {
        float4 clampedColor = min(max(color, 0.0), 1.0);
        color = cos(clampedColor * pi + pi) / 2 + 0.5;
    }
    
    color += uniforms.offset;
    
    color *= uniforms.opacity;
    
    targetTexture.write(float4(color.rgb, alpha), pos);
}

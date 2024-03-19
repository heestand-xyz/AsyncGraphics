//
//  Created by Anton Heestand on 2022-04-22.
//  Copyright © 2022 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct Uniforms {
    packed_float3 translation;
    packed_float3 rotation;
    float scale;
    packed_float3 size;
};

kernel void transform3d(const device Uniforms& uniforms [[ buffer(0) ]],
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
    
    float3 size = float3(uniforms.size.x * uniforms.scale,
                         uniforms.size.y * uniforms.scale,
                         uniforms.size.z * uniforms.scale);
    
    float3 p = float3(u - 0.5 - uniforms.translation.x,
                      v - 0.5 - uniforms.translation.y,
                      w - 0.5 - uniforms.translation.z);
    
    if (uniforms.rotation.x != 0.0) {
        float angx = atan2(p.z, p.y) - uniforms.rotation.x;
        float ampx = sqrt(pow(p.y, 2) + pow(p.z, 2));
        float2 rotx = float2(cos(angx) * ampx, sin(angx) * ampx);
        p = float3(p.x, rotx[0], rotx[1]);
    }
    
    if (uniforms.rotation.y != 0.0) {
        float angy = atan2(p.z, p.x) - uniforms.rotation.y;
        float ampy = sqrt(pow(p.x, 2) + pow(p.z, 2));
        float2 roty = float2(cos(angy) * ampy, sin(angy) * ampy);
        p = float3(roty[0], p.y, roty[1]);
    }
    
    if (uniforms.rotation.z != 0.0) {
        float angz = atan2(p.y, p.x) - uniforms.rotation.z;
        float ampz = sqrt(pow(p.x, 2) + pow(p.y, 2));
        float2 rotz = float2(cos(angz) * ampz, sin(angz) * ampz);
        p = float3(rotz[0], rotz[1], p.z);
    }
    
    float3 uvw = p / size + 0.5;
    
    float4 color = texture.sample(sampler, uvw);
    
    targetTexture.write(color, pos);
}

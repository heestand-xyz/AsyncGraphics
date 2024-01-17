//
//  Created by Anton Heestand on 2017-11-26.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#import "../../../../Shaders/Effects/place_header.metal"

struct Uniforms {
    uint placement;
    packed_float3 translation;
    packed_float3 rotation;
    float scale;
    packed_float3 size;
    float lumaGamma;
};

kernel void lumaTransform3d(const device Uniforms& uniforms [[ buffer(0) ]],
                            texture3d<float, access::write> targetTexture [[ texture(0) ]],
                            texture3d<float, access::sample> leadingTexture [[ texture(1) ]],
                            texture3d<float, access::sample> trailingTexture [[ texture(2) ]],
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
    
    uint leadingWidth = leadingTexture.get_width();
    uint leadingHeight = leadingTexture.get_height();
    uint leadingDepth = leadingTexture.get_depth();
    uint trailingWidth = trailingTexture.get_width();
    uint trailingHeight = trailingTexture.get_height();
    uint trailingDepth = trailingTexture.get_depth();
    float3 uvwPlacement = place3d(uniforms.placement, uvw, leadingWidth, leadingHeight, leadingDepth, trailingWidth, trailingHeight, trailingDepth);
    
    float4 cb = trailingTexture.sample(sampler, uvwPlacement);
    float lum = (cb.r + cb.g + cb.b) / 3;
    lum = pow(lum, 1 / max(0.001, uniforms.lumaGamma));
    
    float3 size = float3(uniforms.size.x * uniforms.scale,
                         uniforms.size.y * uniforms.scale,
                         uniforms.size.z * uniforms.scale);
    
    float3 p = float3(u - 0.5 - uniforms.translation.x,
                      v - 0.5 - uniforms.translation.y,
                      w - 0.5 - uniforms.translation.z);
    
    if (uniforms.rotation.x != 0.0) {
        float angx = atan2(p.z, p.y) + (-uniforms.rotation.x * pi * 2);
        float ampx = sqrt(pow(p.y, 2) + pow(p.z, 2));
        float2 rotx = float2(cos(angx) * ampx, sin(angx) * ampx);
        p = float3(p.x, rotx[0], rotx[1]);
    }
    
    if (uniforms.rotation.y != 0.0) {
        float angy = atan2(p.z, p.x) + (-uniforms.rotation.y * pi * 2);
        float ampy = sqrt(pow(p.x, 2) + pow(p.z, 2));
        float2 roty = float2(cos(angy) * ampy, sin(angy) * ampy);
        p = float3(roty[0], p.y, roty[1]);
    }
    
    if (uniforms.rotation.z != 0.0) {
        float angz = atan2(p.y, p.x) + (-uniforms.rotation.z * pi * 2);
        float ampz = sqrt(pow(p.x, 2) + pow(p.y, 2));
        float2 rotz = float2(cos(angz) * ampz, sin(angz) * ampz);
        p = float3(rotz[0], rotz[1], p.z);
    }
    
    float3 puvw = p / size + 0.5;
    float3 luvw = uvw * (1.0 - lum) + puvw * lum;

    float4 color = leadingTexture.sample(sampler, luvw);
    
    targetTexture.write(color, pos);
}

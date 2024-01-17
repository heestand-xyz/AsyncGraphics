//
//  Created by Anton Heestand on 2017-11-26.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#import "../../../../Shaders/Effects/place_header.metal"

struct Uniforms {
    uint placement;
    float brightness;
    float darkness;
    float contrast;
    float gamma;
    bool invert;
    bool smooth;
    float opacity;
    float offset;
    float lumaGamma;
};

kernel void lumaLevels3d(const device Uniforms& uniforms [[ buffer(0) ]],
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
    
    float4 c = leadingTexture.sample(sampler, uvw);
   
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
    
    float opacity = (1.0 - (1.0 - uniforms.opacity) * lum);
    float a = c.a * opacity;
    
    c *= 1 / (1.0 - uniforms.darkness * lum);
    c -= 1.0 / (1.0 - uniforms.darkness * lum) - 1;
    
    c *= 1.0 - (1.0 - uniforms.brightness) * lum;
    
    c -= 0.5;
    c *= 1.0 + uniforms.contrast * lum;
    c += 0.5;
    
    c = pow(c, 1 / max(0.001, 1.0 - (1.0 - uniforms.gamma) * lum));
    
    if (uniforms.invert) {
        float4 ci = 1.0 - c;
        c = c * (1.0 - lum) + ci * lum;
    }
    
    if (uniforms.smooth) {
        float4 cl = min(max(c, 0.0), 1.0);
        float4 cs = cos(cl * pi + pi) / 2 + 0.5;
        c = c * (1.0 - lum) + cs * lum;
    }
    
    c += uniforms.offset;
    
    c *= opacity;
    
    float4 color = float4(c.r, c.g, c.b, a);
    
    targetTexture.write(color, pos);
}

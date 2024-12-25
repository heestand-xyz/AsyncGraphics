//
//  Created by Anton Heestand on 2017-11-26.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#import "../../../../Shaders/Effects/place_header.metal"
#import "../../../../Shaders/Effects/hsv_header.metal"

struct Uniforms {
    uint type;
    uint placement;
    uint count;
    float radius;
    float angle;
    float light;
    float lumaGamma;
    packed_float3 position;
};

kernel void lumaRainbowBlur3d(const device Uniforms& uniforms [[ buffer(0) ]],
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
    
    float aspectRatio = float(leadingWidth) / float(leadingHeight);
    
    int res = uniforms.count;
    
    float3 p = uniforms.position;
    
    float4 c = 0.0;
    float amounts = 0.0;
    if (uniforms.type == 0) {
        
        // Circle
        
        for (int i = 0; i < res * 3; ++i) {
            float fraction = float(i) / float(res * 3);
            float3 rgb = hsv2rgb(fraction, 1.0, 1.0);
            float4 rgba = float4(rgb.r, rgb.g, rgb.b, 1.0);
            float ang = fraction * pi * 2;
            float xu = u + cos(ang) * uniforms.radius * lum / aspectRatio;
            float yv = v + sin(ang) * uniforms.radius * lum;
            c += leadingTexture.sample(sampler, float3(xu, yv, w)) * rgba;
            amounts += 1.0;
        }
        
    } else if (uniforms.type == 2) {
        
        // Zoom
        
        for (int i = -res; i <= res; ++i) {
            float fraction = (float(i) / float(res)) / 2.0 + 0.5;
            float3 rgb = hsv2rgb(fraction, 1.0, 1.0);
            float4 rgba = float4(rgb.r, rgb.g, rgb.b, 1.0);
            float xu = u + ((float(i) * (u - 0.5 - p.x)) * uniforms.radius * lum / aspectRatio) / res;
            float yv = v + ((float(i) * (v - 0.5 - p.y)) * uniforms.radius * lum) / res;
            float zw = w + ((float(i) * (w - 0.5 - p.z)) * uniforms.radius * lum) / res;
            c += leadingTexture.sample(sampler, float3(xu, yv, zw)) * rgba;
            amounts += 1.0;
        }
        
    }
    
    c *= 2;
    c /= amounts;
    c *= uniforms.light;
    
    targetTexture.write(c, pos);
}



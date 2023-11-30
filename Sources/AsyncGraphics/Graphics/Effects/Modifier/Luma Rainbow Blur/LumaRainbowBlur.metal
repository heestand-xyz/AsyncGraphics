//
//  Created by Anton Heestand on 2017-11-26.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#import "../../../../Shaders/Effects/place_header.metal"
#import "../../../../Shaders/Effects/hsv_header.metal"

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    uint type;
    uint placement;
    uint count;
    float radius;
    float angle;
    float light;
    float lumaGamma;
    packed_float2 position;
};

fragment float4 lumaRainbowBlur(VertexOut out [[stage_in]],
                                texture2d<float> leadingTexture [[ texture(0) ]],
                                texture2d<float> trailingTexture [[ texture(1) ]],
                                const device Uniforms& uniforms [[ buffer(0) ]],
                                sampler s [[ sampler(0) ]]) {
    
    float pi = M_PI_F;
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
   
    uint leadingWidth = leadingTexture.get_width();
    uint leadingHeight = leadingTexture.get_height();
    uint trailingWidth = trailingTexture.get_width();
    uint trailingHeight = trailingTexture.get_height();
    float2 uvPlacement = place(uniforms.placement, uv, leadingWidth, leadingHeight, trailingWidth, trailingHeight);
    
    float4 cb = trailingTexture.sample(s, uvPlacement);
    
    float lum = (cb.r + cb.g + cb.b) / 3;
    lum = pow(lum, 1 / max(0.001, uniforms.lumaGamma));
    
    uint w = leadingWidth;
    uint h = leadingHeight;
    float aspectRatio = float(w) / float(h);
    
    int res = uniforms.count;
    
    float angle = uniforms.angle * pi * 2;
    float2 pos = uniforms.position;
    
    float4 c = 0.0;
    float amounts = 0.0;
    if (uniforms.type == 0) {
        
        // Circle
        
        for (int i = 0; i < res * 3; ++i) {
            float fraction = float(i) / float(res * 3);
            float3 rgb = hsv2rgb(fraction, 1.0, 1.0);
            float4 rgba = float4(rgb.r, rgb.g, rgb.b, 1.0);
            float ang = fraction * pi * 2;
            float xu = u + cos(ang - angle) * uniforms.radius * lum / aspectRatio;
            float yv = v + sin(ang - angle) * uniforms.radius * lum;
            c += leadingTexture.sample(s, float2(xu, yv)) * rgba;
            amounts += 1.0;
        }
        
    } else if (uniforms.type == 1) {
        
        // Angle
        
        for (int x = -res; x <= res; ++x) {
            float fraction = (float(x) / float(res)) / 2.0 + 0.5;
            float3 rgb = hsv2rgb(fraction, 1.0, 1.0);
            float4 rgba = float4(rgb.r, rgb.g, rgb.b, 1.0);
            float xu = u + (float(x) * cos(-angle) * uniforms.radius * lum / aspectRatio) / res;
            float yv = v + (float(x) * sin(-angle) * uniforms.radius * lum) / res;
            c += leadingTexture.sample(s, float2(xu, yv)) * rgba;
            amounts += 1.0;
        }
        
    } else if (uniforms.type == 2) {
        
        // Zoom
        
        for (int x = -res; x <= res; ++x) {
            float fraction = (float(x) / float(res)) / 2.0 + 0.5;
            float3 rgb = hsv2rgb(fraction, 1.0, 1.0);
            float4 rgba = float4(rgb.r, rgb.g, rgb.b, 1.0);
            float xu = u + ((float(x) * (u - 0.5 - pos.x)) * uniforms.radius * lum / aspectRatio) / res;
            float yv = v + ((float(x) * (v - 0.5 - pos.y)) * uniforms.radius * lum) / res;
            c += leadingTexture.sample(s, float2(xu, yv)) * rgba;
            amounts += 1.0;
        }
        
    }
    
    c *= 2;
    c /= amounts;
    c *= uniforms.light;
    
    return c;
}



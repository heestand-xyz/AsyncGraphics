//
//  Created by Anton Heestand on 2017-11-14.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#import "../../../../Shaders/Effects/hsv_header.metal"

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    uint type;
    uint count;
    float radius;
    float angle;
    float light;
    packed_float2 position;
};

fragment float4 rainbowBlur(VertexOut out [[stage_in]],
                            texture2d<float> texture [[ texture(0) ]],
                            const device Uniforms& uniforms [[ buffer(0) ]],
                            sampler sampler [[ sampler(0) ]]) {
    
    float pi = M_PI_F;
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    
    uint iw = texture.get_width();
    uint ih = texture.get_height();
    float aspect = float(iw) / float(ih);
    
    int res = uniforms.count;
    
    float angle = uniforms.angle * pi * 2;
    float2 pos = uniforms.position;
    
    float4 c = 0.0;
    float amounts = 1.0;
    if (uniforms.type == 0) {
        
        // Circle
        
        for (int i = 0; i < res * 3; ++i) {
            float fraction = float(i) / float(res * 3);
            float3 rgb = hsv2rgb(fraction, 1.0, 1.0);
            float4 rgba = float4(rgb.r, rgb.g, rgb.b, 1.0);
            float xu = u;
            float yv = v;
            float ang = fraction * pi * 2;
            xu += cos(ang - angle) * uniforms.radius;
            yv += (sin(ang - angle) * uniforms.radius) * aspect;
            c += texture.sample(sampler, float2(xu, yv)) * rgba;
            amounts += 1.0;
        }
        
    } else if (uniforms.type == 1) {
        
        // Angle
        
        for (int x = -res; x <= res; ++x) {
            float fraction = (float(x) / float(res)) / 2.0 + 0.5;
            float3 rgb = hsv2rgb(fraction, 1.0, 1.0);
            float4 rgba = float4(rgb.r, rgb.g, rgb.b, 1.0);
            float xu = u;
            float yv = v;
            if (aspect < 1.0) {
                xu += (float(x) / res) * cos(-angle) * uniforms.radius;
                yv += ((float(x) / res) * sin(-angle) * uniforms.radius) * aspect;
            } else {
                xu += (float(x) / res) * cos(-angle) * uniforms.radius;
                yv += ((float(x) / res) * sin(-angle) * uniforms.radius) * aspect;
            }
            c += texture.sample(sampler, float2(xu, yv)) * rgba;
            amounts += 1.0;
        }
        
    } else if (uniforms.type == 2) {
        
        // Zoom
        
        for (int x = -res; x <= res; ++x) {
            float fraction = (float(x) / float(res)) / 2.0 + 0.5;
            float3 rgb = hsv2rgb(fraction, 1.0, 1.0);
            float4 rgba = float4(rgb.r, rgb.g, rgb.b, 1.0);
            float xu = u;
            float yv = v;
            if (aspect < 1.0) {
                xu += ((float(x) * (u - 0.5 + pos.x)) / res) * uniforms.radius;
                yv += ((float(x) * (v - 0.5 + pos.y)) / res) * uniforms.radius;
            } else {
                xu += ((float(x) * (u - 0.5 + pos.x)) / res) * uniforms.radius;
                yv += ((float(x) * (v - 0.5 + pos.y)) / res) * uniforms.radius;
            }
            c += texture.sample(sampler, float2(xu, yv)) * rgba;
            amounts += 1.0;
        }
        
    }
    
    c *= 2;
    c /= amounts;
    c *= uniforms.light;
    
    return c;
}



//
//  Created by Anton Heestand on 2017-11-26.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#import "../../../../Metal/Effects/place_header.metal"
#import "../../../../Metal/Content/random_header.metal"

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    uint type;
    uint placement;
    uint count;
    float radius;
    packed_float2 position;
    float angle;
    float gamma;
};

fragment float4 lumaBlur(VertexOut out [[stage_in]],
                         texture2d<float> leadingTexture [[ texture(0) ]],
                         texture2d<float> trailingTexture [[ texture(1) ]],
                         const device Uniforms& uniforms [[ buffer(0) ]],
                         sampler sampler [[ sampler(0) ]]) {
    
    float pi = M_PI_F;
    int max_res = 16384 - 1;
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    float4 ca = leadingTexture.sample(sampler, uv);
    
    uint leadingWidth = leadingTexture.get_width();
    uint leadingHeight = leadingTexture.get_height();
    uint trailingWidth = trailingTexture.get_width();
    uint trailingHeight = trailingTexture.get_height();
    float2 uvPlacement = place(uniforms.placement, uv, leadingWidth, leadingHeight, trailingWidth, trailingHeight);
    
    float4 cb = trailingTexture.sample(sampler, uvPlacement);
    
    float lum = (cb.r + cb.g + cb.b) / 3;
    lum = pow(lum, 1 / max(0.001, uniforms.gamma));
    
    uint w = leadingWidth;
    uint h = leadingHeight;
    float aspectRatio = float(w) / float(h);
    
    int res = uniforms.count;
    
    float angle = uniforms.angle * pi * 2;
    float2 pos = uniforms.position;
    
    float amounts = 1.0;
    
    if (uniforms.type == 0) {
        
        // Box
        
        for (int x = -res; x <= res; ++x) {
            for (int y = -res; y <= res; ++y) {
                if (x != 0 && y != 0) {
                    float dist = sqrt(pow(float(x), 2) + pow(float(y), 2));
                    if (dist <= res) {
                        float amount = pow(1.0 - dist / (res + 1), 0.5);
                        float xu = u + (float(x) * uniforms.radius * lum / aspectRatio) / res;
                        float yv = v + (float(y) * uniforms.radius * lum) / res;
                        ca += leadingTexture.sample(sampler, float2(xu, yv)) * amount;
                        amounts += amount;
                    }
                }
            }
        }
        
    } else if (uniforms.type == 1) {
        
        // Angle
        
        for (int x = -res; x <= res; ++x) {
            if (x != 0) {
                float amount = pow(1.0 - x / (res + 1), 0.5);
                float xu = u + (float(x) * cos(-angle) * uniforms.radius * lum / aspectRatio) / res;
                float yv = v + (float(x) * sin(-angle) * uniforms.radius * lum) / res;
                ca += leadingTexture.sample(sampler, float2(xu, yv)) * amount;
                amounts += amount;
            }
        }
        
    } else if (uniforms.type == 2) {
        
        // Zoom
        
        for (int x = -res; x <= res; ++x) {
            if (x != 0) {
                float amount = pow(1.0 - x / (res + 1), 0.5);
                float xu = u + ((float(x) * (u - 0.5 - pos.x)) * uniforms.radius * lum / aspectRatio) / res;
                float yv = v + ((float(x) * (v - 0.5 + pos.y)) * uniforms.radius * lum) / res;
                ca += leadingTexture.sample(sampler, float2(xu, yv)) * amount;
                amounts += amount;
            }
        }
        
    } else if (uniforms.type == 3) {
        
        // Random
        
        Loki loki_rnd_u = Loki(0, u * max_res, v * max_res);
        float ru = loki_rnd_u.rand();
        Loki loki_rnd_v = Loki(1, u * max_res, v * max_res);
        float rv = loki_rnd_v.rand();
        float2 ruv = uv + (float2(ru, rv) - 0.5) * uniforms.radius * lum * 0.001;
        ca = leadingTexture.sample(sampler, ruv);
        
    }
    
    ca /= amounts;
    
    return ca;
}



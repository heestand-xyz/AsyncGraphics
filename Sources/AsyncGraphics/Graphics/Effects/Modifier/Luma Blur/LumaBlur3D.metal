//
//  Created by Anton Heestand on 2017-11-26.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#import "../../../../Shaders/Effects/place_header.metal"
#import "../../../../Shaders/Content/random_header.metal"

struct Uniforms {
    uint type;
    uint placement;
    uint count;
    float radius;
    packed_float3 position;
    float lumaGamma;
};

kernel void lumaBlur3d(const device Uniforms& uniforms [[ buffer(0) ]],
                       texture3d<float, access::write> targetTexture [[ texture(0) ]],
                       texture3d<float, access::sample> leadingTexture [[ texture(1) ]],
                       texture3d<float, access::sample> trailingTexture [[ texture(2) ]],
                       uint3 pos [[ thread_position_in_grid ]],
                       sampler sampler [[ sampler(0) ]]) {
    
    int max_res = 16384 - 1;
        
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
    
    float4 ca = leadingTexture.sample(sampler, uvw);
    
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
    
    float aspectRatio = float(width) / float(height);
    float depthAspectRatio = float(depth) / float(height);
    
    int res = uniforms.count;
    
    float3 position = uniforms.position;
    
    float amounts = 1.0;
    
    if (uniforms.type == 0) {
        
        // Box
        
        for (int x = -res; x <= res; ++x) {
            for (int y = -res; y <= res; ++y) {
                for (int z = -res; z <= res; ++z) {
                    if (x != 0 && y != 0) {
                        float dist = sqrt(pow(float(x), 2) + pow(float(y), 2) + pow(float(z), 2));
                        if (dist <= res) {
                            float amount = pow(1.0 - dist / (res + 1), 0.5);
                            float xu = u + (float(x) * uniforms.radius * lum / aspectRatio) / res;
                            float yv = v + (float(y) * uniforms.radius * lum) / res;
                            float zw = w + (float(z) * uniforms.radius * lum / depthAspectRatio) / res;
                            ca += leadingTexture.sample(sampler, float3(xu, yv, zw)) * amount;
                            amounts += amount;
                        }
                    }
                }
            }
        }
        
    } else if (uniforms.type == 1) {
        
        // Zoom
        
        for (int x = -res; x <= res; ++x) {
            if (x != 0) {
                float amount = pow(1.0 - x / (res + 1), 0.5);
                float xu = u + ((float(x) * (u - 0.5 - position.x)) * uniforms.radius * lum / aspectRatio) / res;
                float yv = v + ((float(x) * (v - 0.5 - position.y)) * uniforms.radius * lum) / res;
                float zw = w + ((float(x) * (w - 0.5 - position.z)) * uniforms.radius * lum) / res;
                ca += leadingTexture.sample(sampler, float3(xu, yv, zw)) * amount;
                amounts += amount;
            }
        }
        
    } else if (uniforms.type == 2) {
        
        // Random
        
        Loki randomizer = Loki(u * max_res, v * max_res, w * max_res);
        float3 random = float3(randomizer.rand(), randomizer.rand(), randomizer.rand());
        float3 ruvw = uvw + (random - 0.5) * uniforms.radius * lum * 0.001;
        ca = leadingTexture.sample(sampler, ruvw);
        
    }
    
    ca /= amounts;
    
    targetTexture.write(ca, pos);
}

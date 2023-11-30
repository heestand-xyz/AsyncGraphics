//
//  Created by Anton Heestand on 2022-04-22.
//  Copyright © 2022 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#import "../../../../Shaders/Content/random_header.metal"

struct Uniforms {
    int type;
    float radius;
    int count;
    packed_float3 direction;
    packed_float3 position;
};

kernel void blur3d(const device Uniforms& uniforms [[ buffer(0) ]],
                   texture3d<float, access::write>  targetTexture [[ texture(0) ]],
                   texture3d<float, access::sample> texture [[ texture(1) ]],
                   uint3 pos [[ thread_position_in_grid ]],
                   sampler sampler [[ sampler(0) ]]) {
    
    int max_count = 16384 - 1;
        
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
    
    float aspect = float(width) / float(height);
    float depthAspect = float(depth) / float(height);
    
    int count = uniforms.count;
    
    float3 position = uniforms.position;
    
    float radius = uniforms.radius;
    
    int type = uniforms.type;
    
    float amounts = 1.0;
    
    if (type == 0) {
        
        // Box
        
        for (int x = -count; x <= count; ++x) {
            for (int y = -count; y <= count; ++y) {
                for (int z = -count; z <= count; ++z) {
                    if (x != 0 && y != 0 && z != 0) {
                        float dist = sqrt(pow(sqrt(pow(float(x), 2) + pow(float(y), 2)), 2) + pow(float(z), 2));
                        if (dist <= count) {
                            float amount = pow(1.0 - dist / (count + 1), 0.5);
                            float xu = u + (float(x) / count) * radius / aspect;
                            float yv = v + (float(y) / count) * radius;
                            float zw = w + (float(z) / count) * radius / depthAspect;
                            color += texture.sample(sampler, float3(xu, yv, zw)) * amount;
                            amounts += amount;
                        }
                    }
                }
            }
        }
        
    } else if (type == 1) {
        
        // Direction
        
        for (int x = -count; x <= count; ++x) {
            if (x != 0) {
                float amount = pow(1.0 - x / (count + 1), 0.5);
                float xu = u + (float(x) / count) * uniforms.direction.x * radius / aspect;
                float yv = v + (float(x) / count) * uniforms.direction.y * radius;
                float zw = w + (float(x) / count) * uniforms.direction.z * radius / depthAspect;
                color += texture.sample(sampler, float3(xu, yv, zw)) * amount;
                amounts += amount;
            }
        }
        
    } else if (type == 2) {
        
        // Zoom
        
        for (int x = -count; x <= count; ++x) {
            if (x != 0) {
                float amount = pow(1.0 - x / (count + 1), 0.5);
                float xu = u + (float(x) / count) * (u - 0.5 - position.x) * radius / aspect;
                float yv = v + (float(x) / count) * (v - 0.5 - position.y) * radius;
                float zw = w + (float(x) / count) * (w - 0.5 - position.z) * radius / depthAspect;
                color += texture.sample(sampler, float3(xu, yv, zw)) * amount;
                amounts += amount;
            }
        }
        
    } else if (type == 3) {
        
        // Random
        
        int offset = max_count / 3;
        Loki loki_rnd_u = Loki(u * offset, v * offset, w * offset);
        float ru = loki_rnd_u.rand();
        Loki loki_rnd_v = Loki(u * offset + offset, v * offset + offset, w * offset + offset);
        float rv = loki_rnd_v.rand();
        Loki loki_rnd_w = Loki(u * offset + offset * 2, v * offset + offset * 2, w * offset + offset * 2);
        float rw = loki_rnd_w.rand();
        float3 ruvw = uvw + (float3(ru, rv, rw) - 0.5) * radius / float3(aspect, 1.0, depthAspect);
        color = texture.sample(sampler, ruvw);
    }
    
    color /= amounts;
    
    targetTexture.write(color, pos);
}



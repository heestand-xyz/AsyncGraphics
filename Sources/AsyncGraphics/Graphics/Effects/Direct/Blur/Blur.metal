//
//  Created by Anton Heestand on 2017-11-14.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#import "../../../../Metal/Content/random_header.metal"

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    int type;
    float radius;
    int count;
    float angle;
    packed_float2 position;
};

fragment float4 blur(VertexOut out [[stage_in]],
                     texture2d<float>  texture [[ texture(0) ]],
                     const device Uniforms& uniforms [[ buffer(0) ]],
                     sampler sampler [[ sampler(0) ]]) {
    
    float pi = M_PI_F;
    int max_count = 16384 - 1;
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    float4 color = texture.sample(sampler, uv);
    
    uint width = texture.get_width();
    uint height = texture.get_height();
    float aspect = float(width) / float(height);
    
    int count = uniforms.count;
    
    float angle = uniforms.angle * pi * 2;
    float2 position = uniforms.position;
    
    float radius = uniforms.radius;

    int type = uniforms.type;
    
    float amounts = 1.0;
    
    if (type == 1) {
        
        // Box
        
        for (int x = -count; x <= count; ++x) {
            for (int y = -count; y <= count; ++y) {
                if (x != 0 && y != 0) {
                    float dist = sqrt(pow(float(x), 2) + pow(float(y), 2));
                    if (dist <= count) {
                        float amount = pow(1.0 - dist / (count + 1), 0.5);
                        float xu = u + (float(x) / count) * radius / aspect;
                        float yv = v + (float(y) / count) * radius;
                        color += texture.sample(sampler, float2(xu, yv)) * amount;
                        amounts += amount;
                    }
                }
            }
        }
        
    } else if (type == 2) {
        
        // Angle
        
        for (int x = -count; x <= count; ++x) {
            if (x != 0) {
                float amount = pow(1.0 - x / (count + 1), 0.5);
                float xu = u + (float(x) / count) * cos(-angle) * radius / aspect;
                float yv = v + (float(x) / count) * sin(-angle) * radius;
                color += texture.sample(sampler, float2(xu, yv)) * amount;
                amounts += amount;
            }
        }
        
    } else if (type == 3) {
        
        // Zoom
        
        for (int x = -count; x <= count; ++x) {
            if (x != 0) {
                float amount = pow(1.0 - x / (count + 1), 0.5);
                float xu = u + (float(x) / count) * (u - 0.5 - position.x) * radius / aspect;
                float yv = v + (float(x) / count) * (v - 0.5 - position.y) * radius;
                color += texture.sample(sampler, float2(xu, yv)) * amount;
                amounts += amount;
            }
        }
        
    }
//    else if (type == 4) {
//
//        // Circular
//
//        for (int x = -count; x <= count; ++x) {
//            if (x != 0) {
//                float amount = pow(1.0 - x / (count + 1), 0.5);
//                float xu = u + (float(x) / count) * cos(atan2(v - 0.5 - position.y, (u - 0.5) * aspect - position.x) + pi / 2) * radius / aspect;
//                float yv = v + (float(x) / count) * sin(atan2(v - 0.5 - position.y, (u - 0.5) * aspect - position.x) + pi / 2) * radius;
//                color += texture.sample(sampler, float2(xu, yv)) * amount;
//                amounts += amount;
//            }
//        }
//
//    }
    else if (type == 4) {
        
        // Random
        
        Loki loki_rnd_u = Loki(0, u * max_count, v * max_count);
        float ru = loki_rnd_u.rand();
        Loki loki_rnd_v = Loki(1, u * max_count, v * max_count);
        float rv = loki_rnd_v.rand();
        float2 ruv = uv + (float2(ru, rv) - 0.5) * radius * float2(1.0, aspect);
        color = texture.sample(sampler, ruv);
    }
    
    color /= amounts;
    
    return color;
}



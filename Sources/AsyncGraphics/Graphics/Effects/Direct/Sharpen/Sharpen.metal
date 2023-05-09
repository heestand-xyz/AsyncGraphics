//
//  EffectSingleContrastPIX.metal
//  PixelKitShaders
//
//  Created by Anton Heestand on 2017-12-06.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    float sharpness;
    float distance;
};

fragment float4 sharpen(VertexOut out [[stage_in]],
                        texture2d<float> texture [[ texture(0) ]],
                        const device Uniforms& uniforms [[ buffer(0) ]],
                        sampler sampler [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    float width = texture.get_width();
    float height = texture.get_height();
    
    float sharpness = uniforms.sharpness;
    float distance = uniforms.distance;
    
    float4 color = 0;
    color += texture.sample(sampler, uv) * (1 + 8 * sharpness);
    color -= texture.sample(sampler, float2(u - (1.0 / width) * distance,
                                            v - (1.0 / height) * distance)) * sharpness;
    color -= texture.sample(sampler, float2(u - (1.0 / width) * distance,
                                            v)) * sharpness;
    color -= texture.sample(sampler, float2(u - (1.0 / width) * distance,
                                            v + (1.0 / height) * distance)) * sharpness;
    color -= texture.sample(sampler, float2(u,
                                            v - (1.0 / height) * distance)) * sharpness;
    color -= texture.sample(sampler, float2(u,
                                            v + (1.0 / height) * distance)) * sharpness;
    color -= texture.sample(sampler, float2(u + (1.0 / width) * distance,
                                            v - (1.0 / height) * distance)) * sharpness;
    color -= texture.sample(sampler, float2(u + (1.0 / width) * distance,
                                            v)) * sharpness;
    color -= texture.sample(sampler, float2(u + (1.0 / width) * distance,
                                            v + (1.0 / height) * distance)) * sharpness;
    
    return color;
}

//
//  Created by Anton Heestand on 2017-11-14.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    bool monochrome;
    uint levels;
    float strength;
};

constant float4x4 bayerMatrix = float4x4(
    float4( 0.0,  8.0,  2.0, 10.0),
    float4(12.0,  4.0, 14.0,  6.0),
    float4( 3.0, 11.0,  1.0,  9.0),
    float4(15.0,  7.0, 13.0,  5.0)
);

fragment float4 bayerDither(VertexOut out [[stage_in]],
                            texture2d<float> texture [[ texture(0) ]],
                            const device Uniforms& uniforms [[ buffer(0) ]],
                            sampler sampler [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);

    float4 color = texture.sample(sampler, uv);

    float2 position = uv * float2(texture.get_width(), texture.get_height());
    int2 coord = int2(position) % 4;
    
    float threshold = bayerMatrix[coord.y][coord.x] / 16.0;
    threshold = threshold * uniforms.strength;
    
    if (uniforms.monochrome) {
        float luminance = dot(color.rgb, float3(0.299, 0.587, 0.114));
        float bias = (threshold - 0.5) * uniforms.strength;
        float quant = floor(luminance * uniforms.levels + bias) / (uniforms.levels - 1);
        return float4(float3(quant), color.a);
    } else {
        float3 bias = (threshold - 0.5) * uniforms.strength;
        float3 quantized = floor(color.rgb * uniforms.levels + bias) / (uniforms.levels - 1);
        return float4(quantized, color.a);
    }
}

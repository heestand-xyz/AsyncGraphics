//
//  Created by Anton Heestand on 2017-11-18.
//

#include <metal_stdlib>
using namespace metal;

#import "../../../../Shaders/Effects/hsv_header.metal"

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    float hue;
    float saturation;
    packed_float4 tintColor;
};

fragment float4 colorShift(VertexOut out [[stage_in]],
                           texture2d<float>  texture [[ texture(0) ]],
                           const device Uniforms& uniforms [[ buffer(0) ]],
                           sampler sampler [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    float4 color = texture.sample(sampler, uv);
    
    float4 tintColor = uniforms.tintColor;
    
    color *= float4(tintColor.rgb, 1.0);
    
    float3 hsv = rgb2hsv(color.r, color.g, color.b);
    
    hsv[0] += uniforms.hue;
    hsv[1] *= uniforms.saturation;
    
    float3 rgb = hsv2rgb(hsv[0], hsv[1], hsv[2]);
    
    return float4(rgb * tintColor.a, color.a * tintColor.a);
}

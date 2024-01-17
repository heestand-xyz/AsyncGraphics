//
//  Created by Anton Heestand on 2020-06-01.
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
    uint placement;
    float hue;
    float saturation;
    packed_float4 tintColor;
    float lumaGamma;
};

fragment float4 lumaColorShift(VertexOut out [[stage_in]],
                               texture2d<float> leadingTexture [[ texture(0) ]],
                               texture2d<float> trailingTexture [[ texture(1) ]],
                               const device Uniforms& uniforms [[ buffer(0) ]],
                               sampler sampler [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    float4 c = leadingTexture.sample(sampler, uv);
   
    uint leadingWidth = leadingTexture.get_width();
    uint leadingHeight = leadingTexture.get_height();
    uint trailingWidth = trailingTexture.get_width();
    uint trailingHeight = trailingTexture.get_height();
    float2 uvPlacement = place(uniforms.placement, uv, leadingWidth, leadingHeight, trailingWidth, trailingHeight);
    
    float4 cb = trailingTexture.sample(sampler, uvPlacement);
    float lum = (cb.r + cb.g + cb.b) / 3;
    lum = pow(lum, 1 / max(0.001, uniforms.lumaGamma));
    
    c *= float4(1.0 - ((1.0 - uniforms.tintColor.r) * lum),
                1.0 - ((1.0 - uniforms.tintColor.g) * lum),
                1.0 - ((1.0 - uniforms.tintColor.b) * lum),
                1.0);
    
    float3 hsv = rgb2hsv(c.r, c.g, c.b);
    
    hsv[0] += uniforms.hue * lum;
    hsv[1] *= 1.0 + (uniforms.saturation - 1.0) * lum;
    
    float3 cc = hsv2rgb(hsv[0], hsv[1], hsv[2]);
    
    float alpha = 1.0 - ((1.0 - uniforms.tintColor.a) * lum);
    return float4(cc.r * alpha, cc.g * alpha, cc.b * alpha, c.a * alpha);
}

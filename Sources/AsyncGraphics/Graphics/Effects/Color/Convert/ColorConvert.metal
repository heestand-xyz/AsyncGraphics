//
//  Created by Anton Heestand on 2017-11-18.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#import "../../../../Metal/Effects/hsv_header.metal"

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    uint conversion;
    uint index;
};

fragment float4 colorConvert(VertexOut out [[stage_in]],
                             texture2d<float>  inTex [[ texture(0) ]],
                             const device Uniforms& uniforms [[ buffer(0) ]],
                             sampler sampler [[ sampler(0) ]]) {
    
    float2 uv = out.texCoord.rg;
    
    float4 inputColor = inTex.sample(sampler, uv);
        
    float3 color = 0;
    if (uniforms.conversion == 0) {
        color = rgb2hsv(inputColor.r, inputColor.g, inputColor.b);
    } else if (uniforms.conversion == 1) {
        color = hsv2rgb(inputColor.r, inputColor.g, inputColor.b);
    } else {
        return inputColor;
    }
    
    switch (uniforms.index) {
        case 0: // all
            return float4(color.rgb, inputColor.a);
        case 1: // first
            return float4(float3(color.r), inputColor.a);
        case 2: // second
            return float4(float3(color.g), inputColor.a);
        case 3: // third
            return float4(float3(color.b), inputColor.a);
        default:
            return 0.0;
    }
}

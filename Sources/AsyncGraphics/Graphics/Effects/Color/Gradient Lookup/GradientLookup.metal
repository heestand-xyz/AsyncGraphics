//
//  Created by Anton Heestand on 2017-11-14.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#include "../../../../Shaders/Content/gradient_header.metal"

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    float gamma;
};

fragment float4 gradientLookup(VertexOut out [[stage_in]],
                               texture2d<float> texture [[ texture(0) ]],
                               const device Uniforms& uniforms [[ buffer(0) ]],
                               const device array<ColorStopArray, ARRMAX>& colorStops [[ buffer(1) ]],
                               const device array<bool, ARRMAX>& actives [[ buffer(2) ]],
                               sampler sampler [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    float4 color = texture.sample(sampler, uv);
    float fraction = (color.r + color.g + color.b) / 3;
    
    fraction = pow(fraction, 1 / max(0.000001, uniforms.gamma));
    
    float4 sampleColor = gradient(fraction, colorStops, actives);
    
    return sampleColor;
}

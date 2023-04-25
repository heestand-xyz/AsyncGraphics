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
    int axis;
    bool holdEdge;
    float holdEdgeFraction;
    float sampleCoordinate;
};

fragment float4 lookup(VertexOut out [[stage_in]],
                         texture2d<float> leadingTexture [[ texture(0) ]],
                         texture2d<float> trailingTexture [[ texture(1) ]],
                         const device Uniforms& uniforms [[ buffer(0) ]],
                         sampler sampler [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    float4 color = leadingTexture.sample(sampler, uv);
    float luminance = (color.r + color.g + color.b) / 3;
    if (uniforms.holdEdge) {
        if (luminance < uniforms.holdEdgeFraction * 4) {
            luminance = uniforms.holdEdgeFraction * 4;
        } else if (luminance > 1 - uniforms.holdEdgeFraction * 4) {
            luminance = 1 - uniforms.holdEdgeFraction * 4;
        }
    }
    
    float2 sampleUV = uniforms.sampleCoordinate;
    if (uniforms.axis == 0) {
        sampleUV[0] = luminance;
    } else {
        sampleUV[1] = luminance;
    }
    float4 sampleColor = trailingTexture.sample(sampler, sampleUV);
    
    return float4(sampleColor.r, sampleColor.g, sampleColor.b, color.a);
}



//
//  Created by Anton Heestand on 2017-11-26.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#import "../../../../Shaders/Effects/place_header.metal"

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    uint placement;
    float brightness;
    float darkness;
    float contrast;
    float gamma;
    bool invert;
    bool smooth;
    float opacity;
    float offset;
    float lumaGamma;
};

fragment float4 lumaLevels(VertexOut out [[stage_in]],
                           texture2d<float> leadingTexture [[ texture(0) ]],
                           texture2d<float> trailingTexture [[ texture(1) ]],
                           const device Uniforms& uniforms [[ buffer(0) ]],
                           sampler sampler [[ sampler(0) ]]) {
    
    float pi = M_PI_F;
    
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
    
    float opacity = (1.0 - (1.0 - uniforms.opacity) * lum);
    float a = c.a * opacity;
    
    c *= 1 / (1.0 - uniforms.darkness * lum);
    c -= 1.0 / (1.0 - uniforms.darkness * lum) - 1;
    
    c *= 1.0 - (1.0 - uniforms.brightness) * lum;
    
    c -= 0.5;
    c *= 1.0 + uniforms.contrast * lum;
    c += 0.5;
    
    c = pow(c, 1 / max(0.001, 1.0 - (1.0 - uniforms.gamma) * lum));
    
    if (uniforms.invert) {
        float4 ci = 1.0 - c;
        c = c * (1.0 - lum) + ci * lum;
    }
    
    if (uniforms.smooth) {
        float4 cl = min(max(c, 0.0), 1.0);
        float4 cs = cos(cl * pi + pi) / 2 + 0.5;
        c = c * (1.0 - lum) + cs * lum;
    }
    
    c += uniforms.offset;
    
    c *= opacity;
    
    return float4(c.r, c.g, c.b, a);
}



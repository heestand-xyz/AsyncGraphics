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
    packed_float2 translation;
    float rotation;
    float scale;
    packed_float2 size;
    float lumaGamma;
};

fragment float4 lumaTransform(VertexOut out [[stage_in]],
                              texture2d<float> leadingTexture [[ texture(0) ]],
                              texture2d<float> trailingTexture [[ texture(1) ]],
                              const device Uniforms& uniforms [[ buffer(0) ]],
                              sampler sampler [[ sampler(0) ]]) {
    
    float pi = M_PI_F;
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
   
    uint leadingWidth = leadingTexture.get_width();
    uint leadingHeight = leadingTexture.get_height();
    uint trailingWidth = trailingTexture.get_width();
    uint trailingHeight = trailingTexture.get_height();
    float2 uvPlacement = place(uniforms.placement, uv, leadingWidth, leadingHeight, trailingWidth, trailingHeight);
    
    float4 cb = trailingTexture.sample(sampler, uvPlacement);
    float lum = (cb.r + cb.g + cb.b) / 3;
    lum = pow(lum, 1 / max(0.001, uniforms.lumaGamma));
    
    uint w = leadingWidth;
    uint h = leadingHeight;
    float aspect = float(w) / float(h);
    
    float2 size = float2(uniforms.size.x * uniforms.scale,
                         uniforms.size.y * uniforms.scale);
    
    float ang = atan2(v - 0.5 - uniforms.translation.y, (u - 0.5) * aspect - uniforms.translation.x) + (-uniforms.rotation * pi * 2);
    float amp = sqrt(pow((u - 0.5) * aspect - uniforms.translation.x, 2) + pow(v - 0.5 - uniforms.translation.y, 2));
    float2 tuv = float2((cos(ang) / aspect) * amp, sin(ang) * amp) / size + 0.5;
    float2 luv = uv * (1.0 - lum) + tuv * lum;
    float4 c = leadingTexture.sample(sampler, luv);
    
    return c;
}



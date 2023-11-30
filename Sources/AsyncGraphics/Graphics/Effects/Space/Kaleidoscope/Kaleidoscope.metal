//
//  EffectSingleKaleidoscopePIX.metal
//  PixelKit Shaders
//
//  Created by Anton Heestand on 2017-11-28.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;


struct VertexOut{
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    bool mirror;
    int divisions;
    float rotation;
    float scale;
    packed_float2 position;
};

fragment float4 kaleidoscope(VertexOut out [[stage_in]],
                             texture2d<float> inTex [[ texture(0) ]],
                             const device Uniforms& uniforms [[ buffer(0) ]],
                             sampler s [[ sampler(0) ]]) {
    
    float pi = M_PI_F;
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    
    uint w = inTex.get_width();
    uint h = inTex.get_height();
    float aspect = float(w) / float(h);
    
    float x = uniforms.position.x;
    float y = uniforms.position.y;
    
    float rot = uniforms.rotation - 0.25;
    float div = float(uniforms.divisions);
    
    float ang = atan2(v - 0.5 - y, (u - 0.5) * aspect - x) / (pi * 2) + 0.25;
    float ang_big = (ang - rot) * div;
    float ang_step = ang_big - floor(ang_big);
    if (uniforms.mirror) {
        if ((ang_big / 2) - floor(ang_big / 2) > 0.5) {
            ang_step = 1.0 - ang_step;
        }
    }
    float ang_kaleid = (ang_step / div + rot) * (pi * 2);
    float dist = sqrt(pow((u - 0.5) * aspect - x, 2) + pow(v - 0.5 + y, 2)) / uniforms.scale / sqrt(0.75);
    float2 uv = float2((cos(ang_kaleid) / aspect) * dist + x, sin(ang_kaleid) * dist - y) + 0.5;
    
    float4 c = inTex.sample(s, uv);
    
    return c;
}

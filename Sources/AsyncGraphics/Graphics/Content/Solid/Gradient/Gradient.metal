//
//  Created by Anton Heestand on 2017-11-16.
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
    int type;
    int extend;
    float scale;
    float offset;
    packed_float2 position;
    float gamma;
    bool premultiply;
    packed_float2 resolution;
};

fragment float4 gradient(VertexOut out [[stage_in]],
                         const device Uniforms& uniforms [[ buffer(0) ]],
                         const device array<ColorStopArray, ARRMAX>& colorStops [[ buffer(1) ]],
                         const device array<bool, ARRMAX>& actives [[ buffer(2) ]],
                         sampler s [[ sampler(0) ]]) {
    
    float pi = M_PI_F;
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    
    float2 resolution = uniforms.resolution;
    float aspectRatio = resolution.x / resolution.y;
    
    u -= uniforms.position.x / aspectRatio;
    v -= uniforms.position.y;
    
    float fraction = 0;
    if (uniforms.type == 0) {
        // Horizontal
        fraction = (u - uniforms.offset) / uniforms.scale;
    } else if (uniforms.type == 1) {
        // Vertical
        fraction = (v - uniforms.offset) / uniforms.scale;
    } else if (uniforms.type == 2) {
        // Radial
        // TODO: Invert so zero is in the center
        fraction = 1.0 - (sqrt(pow((u - 0.5) * aspectRatio, 2) + pow(v - 0.5, 2)) * 2 - uniforms.offset) / uniforms.scale;
    } else if (uniforms.type == 3) {
        // Angle
        fraction = 1.0 - (atan2((-u + 0.5) * aspectRatio, -(v - 0.5)) / (pi * 2) + 0.5 - uniforms.offset) / uniforms.scale;
    }
    
    FractionAndZero fz = fractionAndZero(fraction, uniforms.extend);
    fraction = fz.fraction;
    
    if (uniforms.gamma != 1.0) {
        fraction = pow(min(max(fraction, 0.0), 1.0), 1 / max(0.000001, uniforms.gamma));
    }
    
    float4 c = 0;
    if (!fz.zero) {
        c = gradient(fraction, colorStops, actives);
    }
    
    if (!fz.zero && uniforms.premultiply) {
        c = float4(c.r * c.a, c.g * c.a, c.b * c.a, c.a);
    }
    
    return c;
}

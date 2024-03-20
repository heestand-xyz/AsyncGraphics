//
//  Created by Anton Heestand on 2017-11-16.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#include "../../../../Shaders/Content/gradient_header.metal"

struct Uniforms {
    int type;
    int extend;
    float scale;
    float offset;
    packed_float3 position;
    float gamma;
    bool premultiply;
    packed_float3 resolution;
    packed_float3 tileOrigin;
    packed_float3 tileSize;
};

kernel void gradient3d(const device Uniforms& uniforms [[ buffer(0) ]],
                       texture3d<float, access::write>  targetTexture [[ texture(0) ]],
                       texture3d<float, access::sample> texture [[ texture(1) ]],
                       const device array<ColorStopArray, ARRMAX>& colorStops [[ buffer(1) ]],
                       const device array<bool, ARRMAX>& actives [[ buffer(2) ]],
                       uint3 pos [[ thread_position_in_grid ]],
                       sampler s [[ sampler(0) ]]) {
    
    uint width = targetTexture.get_width();
    uint height = targetTexture.get_height();
    uint depth = targetTexture.get_depth();
    
    if (pos.x >= width || pos.y >= height || pos.z >= depth) {
        return;
    }
    
    float u = float(pos.x + 0.5) / float(width);
    float v = float(pos.y + 0.5) / float(height);
    float w = float(pos.z + 0.5) / float(depth);
    u = u * uniforms.tileSize.x + uniforms.tileOrigin.x;
    v = v * uniforms.tileSize.y + uniforms.tileOrigin.y;
    w = w * uniforms.tileSize.z + uniforms.tileOrigin.z;
    
    float3 resolution = uniforms.resolution;
    float aspectRatio = resolution.x / resolution.y;
    float depthAspectRatio = resolution.z / resolution.y;
    
    u -= uniforms.position.x / aspectRatio;
    v -= uniforms.position.y;
    w -= uniforms.position.z / depthAspectRatio;
    
    float fraction = 0;
    if (uniforms.type == 0) {
        // X
        fraction = (u - uniforms.offset) / uniforms.scale;
    } else if (uniforms.type == 1) {
        // Y
        fraction = (v - uniforms.offset) / uniforms.scale;
    } else if (uniforms.type == 2) {
        // Z
        fraction = (w - uniforms.offset) / uniforms.scale;
    } else if (uniforms.type == 3) {
        // Radial
        fraction = (sqrt(pow((u - 0.5) * aspectRatio, 2) + pow(v - 0.5, 2) + pow((w - 0.5) * depthAspectRatio, 2)) * 2 - uniforms.offset) / uniforms.scale;
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
    
    targetTexture.write(c, pos);
}

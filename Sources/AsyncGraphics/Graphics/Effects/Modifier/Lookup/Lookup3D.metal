//
//  Created by Anton Heestand on 2017-11-14.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct Uniforms {
    int axis;
    bool holdEdge;
    float holdEdgeFraction;
    float sampleCoordinate;
};

kernel void lookup3d(const device Uniforms& uniforms [[ buffer(0) ]],
                     texture3d<float, access::write>  targetTexture [[ texture(0) ]],
                     texture3d<float, access::sample> leadingTexture [[ texture(1) ]],
                     texture3d<float, access::sample> trailingTexture [[ texture(2) ]],
                     uint3 pos [[ thread_position_in_grid ]],
                     sampler sampler [[ sampler(0) ]]) {
    
    uint width = targetTexture.get_width();
    uint height = targetTexture.get_height();
    uint depth = targetTexture.get_depth();
    
    if (pos.x >= width || pos.y >= height || pos.z >= depth) {
        return;
    }
    
    float u = float(pos.x + 0.5) / float(width);
    float v = float(pos.y + 0.5) / float(height);
    float w = float(pos.z + 0.5) / float(depth);
    float3 uvw = float3(u, v, w);
    
    float4 color = leadingTexture.sample(sampler, uvw);
    float luminance = (color.r + color.g + color.b) / 3;
    if (uniforms.holdEdge) {
        if (luminance < uniforms.holdEdgeFraction * 4) {
            luminance = uniforms.holdEdgeFraction * 4;
        } else if (luminance > 1 - uniforms.holdEdgeFraction * 4) {
            luminance = 1 - uniforms.holdEdgeFraction * 4;
        }
    }
    
    float3 sampleUVW = uniforms.sampleCoordinate;
    if (uniforms.axis == 0) {
        sampleUVW[0] = luminance;
    } else if (uniforms.axis == 1) {
        sampleUVW[1] = luminance;
    } else {
        sampleUVW[2] = luminance;
    }
    float4 sampleColor = trailingTexture.sample(sampler, sampleUVW);
    
    float4 targetColor = float4(sampleColor.r, sampleColor.g, sampleColor.b, color.a);
    targetTexture.write(targetColor, pos);
}



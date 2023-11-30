//
//  Created by Anton Heestand on 2017-11-14.
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
    float offset;
    packed_float3 origin;
    uint placement;
};

kernel void displace3d(const device Uniforms& uniforms [[ buffer(0) ]],
                       texture3d<float, access::write> targetTexture [[ texture(0) ]],
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
    
    uint leadingWidth = leadingTexture.get_width();
    uint leadingHeight = leadingTexture.get_height();
    uint leadingDepth = leadingTexture.get_depth();
    uint trailingWidth = trailingTexture.get_width();
    uint trailingHeight = trailingTexture.get_height();
    uint trailingDepth = trailingTexture.get_depth();
    float3 uvwPlacement = place3d(uniforms.placement, uvw, leadingWidth, leadingHeight, leadingDepth, trailingWidth, trailingHeight, trailingDepth);
    
    float4 sampleColor = trailingTexture.sample(sampler, uvwPlacement);
    float3 sampleUVW = float3(u + (sampleColor.r - uniforms.origin.x) * uniforms.offset,
                              v + (sampleColor.g - uniforms.origin.y) * uniforms.offset,
                              w + (sampleColor.b - uniforms.origin.z) * uniforms.offset);
    
    float4 color = leadingTexture.sample(sampler, sampleUVW);
    
    targetTexture.write(color, pos);
}



//
//  Created by Anton Heestand on 2017-11-14.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#import "../../../../Metal/Effects/place_header.metal"

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    float offset;
    float2 origin;
    int placement;
};

fragment float4 displace(VertexOut out [[stage_in]],
                         texture2d<float> leadingTexture [[ texture(0) ]],
                         texture2d<float> trailingTexture [[ texture(1) ]],
                         const device Uniforms& uniforms [[ buffer(0) ]],
                         sampler sampler [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    uint leadingWidth = leadingTexture.get_width();
    uint leadingHeight = leadingTexture.get_height();
    uint trailingWidth = trailingTexture.get_width();
    uint trailingHeight = trailingTexture.get_height();
    float2 uvPlacement = place(int(uniforms.placement), uv, leadingWidth, leadingHeight, trailingWidth, trailingHeight);
    
    float4 sampleColor = trailingTexture.sample(sampler, uvPlacement);
    float2 sampleUV = float2(u + (-(sampleColor.r - 0.5) + 0.5 - uniforms.origin.x) * uniforms.offset,
                             v + (sampleColor.g - uniforms.origin.y) * uniforms.offset);
    
    float4 color = leadingTexture.sample(sampler, sampleUV);
    
    return color;
}



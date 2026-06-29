//
//  Created by Anton Heestand on 2017-11-28.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//
#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    bool fullRange;
};

fragment float4 yuvToRGB(VertexOut out [[stage_in]],
                         const device Uniforms& uniforms [[buffer(0)]],
                         texture2d<float> yTexture [[texture(0)]],
                         texture2d<float> uvTexture [[texture(1)]],
                         sampler sampler [[sampler(0)]]) {
    
    float2 uv = out.texCoord;
    
    float y = yTexture.sample(sampler, uv).r;
    
    if (!uniforms.fullRange) {
        y = (y - 16.0 / 255.0) * (255.0 / 219.0);
    }
    
    float2 cbcr = uvTexture.sample(sampler, uv).rg;
    float cb = cbcr.x - 0.5;
    float cr = cbcr.y - 0.5;
    
    // BT.709 YCbCr -> RGB
    float3 rgb;
    rgb.r = y + 1.5748 * cr;
    rgb.g = y - 0.1873 * cb - 0.4681 * cr;
    rgb.b = y + 1.8556 * cb;
    
    return float4(saturate(rgb), 1.0);
}

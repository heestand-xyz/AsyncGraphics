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

// BT.709 YUV to RGB conversion matrix
constant float3x3 yuvToRGBMatrix = float3x3(
    1.075,  1.075,  1.075,  // Y
    0.000, -0.392,  2.017,  // U
    1.596, -0.813,  0.000   // V
);

fragment float4 yuvToRGB(VertexOut out [[stage_in]],
                          texture2d<float> yTexture [[ texture(0) ]],
                          texture2d<float> uvTexture [[ texture(1) ]],
                          sampler sampler [[ sampler(0) ]]) {
    
    float2 uv = float2(out.texCoord[0], out.texCoord[1]);
    
    float yColor = yTexture.sample(sampler, uv).r;
    float y = yColor; //(yColor - (16.0 / 255.0)) * (255.0 / (235.0 - 16.0));
    float2 uvColor = uvTexture.sample(sampler, uv).rg;
    float u = uvColor.r - 0.5;
    float v = uvColor.g - 0.5;
    float3 rgb = yuvToRGBMatrix * float3(y, u, v);
    return float4(rgb, 1.0);
}

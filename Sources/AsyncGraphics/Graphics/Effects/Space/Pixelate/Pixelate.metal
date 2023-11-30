//
//  Created by Anton Heestand on 2017-11-30.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    float fraction;
};

fragment float4 pixelate(VertexOut out [[stage_in]],
                         texture2d<float> texture [[ texture(0) ]],
                         const device Uniforms& uniforms [[ buffer(0) ]],
                         sampler sampler [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    float aspectRatio = float(texture.get_width()) / float(texture.get_height());
    
    float fraction = min(max(uniforms.fraction, 0.0), 1.0);
//    fraction = 1.0 / float(int(1.0 / fraction));
//    fraction = pow(1.0 / float(int(pow(1.0 / fraction, 0.5))), 2.0);
    float2 scale = float2(fraction / aspectRatio, fraction);
    float2 pixelUV = uniforms.fraction > 0.0
    ? float2(int2(round((uv - 0.5) / scale))) * scale + 0.5
    : uv;
    
    float4 color = texture.sample(sampler, pixelUV);
    
    return color;
}

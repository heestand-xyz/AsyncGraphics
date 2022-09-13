//
//  Created by Anton Heestand on 2017-12-15.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#import "../../../../Metal/Effects/hsv_header.metal"

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    bool premultiply;
    packed_float4 keyColor;
    float range;
    float softness;
    float edgeDesaturation;
    float alphaCrop;
};

fragment float4 chromaKey(VertexOut out [[stage_in]],
                          texture2d<float> texture [[ texture(0) ]],
                          const device Uniforms& uniforms [[ buffer(0) ]],
                          sampler sampler [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    float3 ck_hsv = rgb2hsv(uniforms.keyColor.r, uniforms.keyColor.g, uniforms.keyColor.b);
    
    float4 c = texture.sample(sampler, uv);
    
    float3 c_hsv = rgb2hsv(c.r, c.g, c.b);
    
    float ck_h = abs(c_hsv[0] - ck_hsv[0]) - uniforms.range;
    
    float ck = (ck_h + (uniforms.softness) / 2) / uniforms.softness;
    if (ck < 0.0) {
        ck = 0.0;
    } else if (ck > 1.0) {
        ck = 1.0;
    }
    
    ck = max(ck, 1.0 - c_hsv[1]);
    ck = max(ck, 1.0 - c_hsv[2]);
    
    float edge_sat = 1 - uniforms.edgeDesaturation;
    if (edge_sat < 0) { edge_sat = 0; }
    else if (edge_sat > 1) { edge_sat = 1; }
    c_hsv[1] *= mix(edge_sat, 1.0, pow(ck, 10));
    
    float3 ck_c = hsv2rgb(c_hsv[0], c_hsv[1], c_hsv[2]);
    
    float invertedAlphaCrop = 1.0 - min(1.0, max(0.0, uniforms.alphaCrop));
    ck = min(1.0, max(0.0, 1.0 - ((1.0 - ck) / invertedAlphaCrop)));
    
    if (uniforms.premultiply) {
        ck_c *= ck;
    }
    
    float a = ck * c.a;
    
    return float4(ck_c.r, ck_c.g, ck_c.b, a);
}

//
//  Created by Anton Heestand on 2017-11-07.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    float brightness;
    float darkness;
    float contrast;
    float gamma;
    bool invert;
    bool smooth;
    float opacity;
    float offset;
    bool premultiply;
    float3 padding;
};

fragment float4 levels(VertexOut out [[stage_in]],
                       texture2d<float>  texture [[ texture(0) ]],
                       const device Uniforms& uniforms [[ buffer(0) ]],
                       sampler sampler [[ sampler(0) ]]) {
    
    float pi = M_PI_F;
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    float4 color = texture.sample(sampler, uv);
    
    float alpha = color.a * uniforms.opacity;
    
    color *= 1.0 / (1.0 - uniforms.darkness);
    color -= 1.0 / (1.0 - uniforms.darkness) - 1.0;
    
    color *= uniforms.brightness;
    
    color -= 0.5;
    color *= 1.0 + uniforms.contrast;
    color += 0.5;
    
    color = pow(color, 1 / max(0.000001, uniforms.gamma));
    
    if (uniforms.invert) {
        color = 1.0 - color;
    }
    
    if (uniforms.smooth) {
        float4 clampedColor = min(max(color, 0.0), 1.0);
        color = cos(clampedColor * pi + pi) / 2 + 0.5;
    }
    
    color += uniforms.offset;
    
    if (uniforms.premultiply) {
        color *= uniforms.opacity;
    }
    
    return float4(color.rgb, alpha);
}



//
//  Created by Anton Heestand on 2017-11-10.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    int mode;
};

fragment float4 blends(VertexOut out [[stage_in]],
                       texture2d_array<float>  textures [[ texture(0) ]],
                       const device Uniforms& uniforms [[ buffer(0) ]],
                       sampler s [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    uint count = textures.get_array_size();
    
    float4 c = 0;
    float4 ci;
    for (uint i = 0; i < count; ++i) {
        uint ir = count - i - 1;
        switch (uniforms.mode) {
            case 0: // Over
                ci = textures.sample(s, uv, i);
                if (i == 0) {
                    c = ci;
                } else {
                    float3 c_rgb = float3(c);
                    float3 ci_rgb = float3(ci);
                    c = float4(c_rgb * (1.0 - ci.a) + ci_rgb, max(c.a, ci.a));
                }
                break;
            case 1: // Under
                ci = textures.sample(s, uv, ir);
                if (i == 0) {
                    c = ci;
                } else {
                    float3 c_rgb = float3(c);
                    float3 ci_rgb = float3(ci);
                    c = float4(c_rgb * (1.0 - ci.a) + ci_rgb, max(c.a, ci.a));
                }
                break;
            case 18: // Screen
                ci = textures.sample(s, uv, i);
                if (i == 0) {
                    c = ci;
                } else {
                    c = float4(1.0 - (1.0 - c.rgb) * (1.0 - ci.rgb), max(c.a, ci.a));
                }
                break;
            case 19: // Lighten
                ci = textures.sample(s, uv, i);
                if (i == 0) {
                    c = ci;
                } else {
                    c = float4(max(c.rgb, ci.rgb), max(c.a, ci.a));
                }
                break;
            case 20: // Darken
                ci = textures.sample(s, uv, i);
                if (i == 0) {
                    c = ci;
                } else {
                    c = float4(min(c.rgb, ci.rgb), min(c.a, ci.a));
                }
                break;
            case 2: // Add Color
                ci = textures.sample(s, uv, i);
                if (i == 0) {
                    c = ci;
                } else {
                    float3 c_rgb = float3(c);
                    float3 ci_rgb = float3(ci);
                    c = float4(c_rgb + ci_rgb, max(c.a, ci.a));
                }
                break;
            case 3: // Add
                ci = textures.sample(s, uv, i);
                if (i == 0) {
                    c = ci;
                } else {
                    c += ci;
                }
                break;
            case 4: // Mult
                ci = textures.sample(s, uv, i);
                if (i == 0) {
                    c = ci;
                } else {
                    c *= ci;
                }
                break;
            case 5: // Diff
                ci = textures.sample(s, uv, i);
                if (i == 0) {
                    c = ci;
                } else {
                    float3 c_rgb = float3(c);
                    float3 ci_rgb = float3(ci);
                    c = float4(abs(c_rgb - ci_rgb), max(c.a, ci.a));
                }
                break;
            case 6: // Sub Color
                ci = textures.sample(s, uv, i);
                if (i == 0) {
                    c = ci;
                } else {
                    float3 c_rgb = float3(c);
                    float3 ci_rgb = float3(ci);
                    c = float4(c_rgb - ci_rgb, max(c.a, ci.a));
                }
                break;
            case 7: // Sub
                ci = textures.sample(s, uv, i);
                if (i == 0) {
                    c = ci;
                } else {
                    c -= ci;
                }
                break;
            case 8: // Max
                ci = textures.sample(s, uv, i);
                if (i == 0) {
                    c = ci;
                } else {
                    c = max(c, ci);
                }
                break;
            case 9: // Min
                ci = textures.sample(s, uv, i);
                if (i == 0) {
                    c = ci;
                } else {
                    c = min(c, ci);
                }
                break;
            case 10: // Gamma
                ci = textures.sample(s, uv, i);
                if (i == 0) {
                    c = ci;
                } else {
                    c = pow(c, 1 / ci);
                }
                break;
            case 11: // Power
                ci = textures.sample(s, uv, i);
                if (i == 0) {
                    c = ci;
                } else {
                    c = pow(c, ci);
                }
                break;
            case 12: // Divide
                ci = textures.sample(s, uv, i);
                if (i == 0) {
                    c = ci;
                } else {
                    c /= ci;
                }
                break;
            case 13: // Average
                ci = textures.sample(s, uv, i);
                if (i == 0) {
                    c = ci / count;
                } else {
                    c += ci / count;
                }
                break;
        }
    }
    
    return c;
}

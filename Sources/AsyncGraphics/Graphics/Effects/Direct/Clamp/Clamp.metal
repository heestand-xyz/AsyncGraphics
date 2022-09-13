//
//  Created by Anton Heestand on 2019-04-01.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    bool includeAlpha;
    uint type;
    float low;
    float high;
};

float clampValue(float value, float low, float high, int type) {
    float rel = 0.0;
    float vala = 0.0;
    float valb = 0.0;
    if (type == 1 || type == 2 || type == 4) {
        rel = (value - low) / (high - low);
        if (rel > 0.0) {
            vala = rel - float(int(rel));
        } else {
            valb = rel + float(int(1.0 - rel));
        }
    }
    switch (type) {
        case 0: // hold
            if (value < low) {
                return low;
            } else if (value > high) {
                return high;
            }
            return value;
        case 1: // relativeLoop
            if (rel > 0.0) {
                return vala;
            } else {
                return valb;
            }
        case 2: // relativeMirror
            if (rel > 0.0) {
                return int(rel) % 2 == 0 ? 1.0 - vala : vala;
            } else {
                return int(1.0 - rel) % 2 == 0 ? 1.0 - valb : valb;
            }
        case 3: // zero
            if (value < low || value > high) {
                return 0.0;
            }
            return value;
        case 4: // relative
            if (value < low) {
                return 0.0;
            } else if (value > high) {
                return 1.0;
            }
            return rel;
        default: return 0.0;
    }
}

fragment float4 clamp(VertexOut out [[stage_in]],
                      texture2d<float> texture [[ texture(0) ]],
                      const device Uniforms& uniforms [[ buffer(0) ]],
                      sampler sampler [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    float4 c = texture.sample(sampler, uv);
    
    float r = clampValue(c.r, uniforms.low, uniforms.high, uniforms.type);
    float g = clampValue(c.g, uniforms.low, uniforms.high, uniforms.type);
    float b = clampValue(c.b, uniforms.low, uniforms.high, uniforms.type);
    float a = uniforms.includeAlpha ? clampValue(c.a, uniforms.low, uniforms.high, uniforms.type) : c.a;
    
    return float4(r, g, b, a);
}

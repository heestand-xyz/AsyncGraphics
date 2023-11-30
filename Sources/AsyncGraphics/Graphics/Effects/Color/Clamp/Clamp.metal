//
//  Created by Anton Heestand on 2019-04-01.
//

#include <metal_stdlib>
using namespace metal;

#import "../../../../Metal/Effects/clamp_header.metal"

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

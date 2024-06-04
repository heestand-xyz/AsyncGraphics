//
//  Created by Anton Heestand on 2024-06-04.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    bool includeAlpha;
    float inLow;
    float inHigh;
    float outLow;
    float outHigh;
};

fragment float4 range(VertexOut out [[stage_in]],
                      texture2d<float> texture [[ texture(0) ]],
                      const device Uniforms& uniforms [[ buffer(0) ]],
                      sampler sampler [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    float4 c = texture.sample(sampler, uv);
    
    float4 rc = (c - uniforms.inLow) / max(0.000001, uniforms.inHigh - uniforms.inLow);
    rc = rc * (uniforms.outHigh - uniforms.outLow) + uniforms.outLow;
    
    return float4(rc.rgb, uniforms.includeAlpha ? rc.a : c.a);
}

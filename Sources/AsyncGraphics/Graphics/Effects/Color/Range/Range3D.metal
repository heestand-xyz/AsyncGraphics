//
//  Created by Anton Heestand on 2024-06-04.
//

#include <metal_stdlib>
using namespace metal;

struct Uniforms {
    bool includeAlpha;
    float inLow;
    float inHigh;
    float outLow;
    float outHigh;
};

kernel void range3d(texture3d<float, access::write>  targetTexture [[ texture(0) ]],
                    texture3d<float, access::sample> texture [[ texture(1) ]],
                    uint3 pos [[ thread_position_in_grid ]],
                    const device Uniforms& uniforms [[ buffer(0) ]],
                    sampler sampler [[ sampler(0) ]]) {
    
    uint width = targetTexture.get_width();
    uint height = targetTexture.get_height();
    uint depth = targetTexture.get_depth();
    
    if (pos.x >= width || pos.y >= height || pos.z >= depth) {
        return;
    }
    
    float u = float(pos.x + 0.5) / float(width);
    float v = float(pos.y + 0.5) / float(height);
    float w = float(pos.z + 0.5) / float(depth);
    float3 uvw = float3(u, v, w);
    
    float4 c = texture.sample(sampler, uvw);
    
    float4 rc = (c - uniforms.inLow) / max(0.000001, uniforms.inHigh - uniforms.inLow);
    rc = rc * (uniforms.outHigh - uniforms.outLow) + uniforms.outLow;
    
    float4 color = float4(rc.rgb, uniforms.includeAlpha ? rc.a : c.a);
    
    targetTexture.write(color, pos);
}

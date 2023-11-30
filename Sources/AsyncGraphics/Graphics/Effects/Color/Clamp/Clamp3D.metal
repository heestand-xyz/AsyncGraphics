//
//  Created by Anton Heestand on 2019-04-01.
//

#include <metal_stdlib>
using namespace metal;

#import "../../../../Shaders/Effects/clamp_header.metal"

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

kernel void clamp3d(texture3d<float, access::write>  targetTexture [[ texture(0) ]],
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
    
    float r = clampValue(c.r, uniforms.low, uniforms.high, uniforms.type);
    float g = clampValue(c.g, uniforms.low, uniforms.high, uniforms.type);
    float b = clampValue(c.b, uniforms.low, uniforms.high, uniforms.type);
    float a = uniforms.includeAlpha ? clampValue(c.a, uniforms.low, uniforms.high, uniforms.type) : c.a;
    
    float4 color = float4(r, g, b, a);
    targetTexture.write(color, pos);
}

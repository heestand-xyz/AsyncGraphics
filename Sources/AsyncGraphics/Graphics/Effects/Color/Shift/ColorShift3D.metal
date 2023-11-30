//
//  Created by Anton Heestand on 2017-11-18.
//

#include <metal_stdlib>
using namespace metal;

#import "../../../../Shaders/Effects/hsv_header.metal"

struct Uniforms {
    float hue;
    float saturation;
    packed_float4 tintColor;
};

kernel void colorShift3d(const device Uniforms& uniforms [[ buffer(0) ]],
                         texture3d<float, access::write>  targetTexture [[ texture(0) ]],
                         texture3d<float, access::sample> texture [[ texture(1) ]],
                         uint3 pos [[ thread_position_in_grid ]],
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
    
    float4 color = texture.sample(sampler, uvw);
    
    float4 tintColor = uniforms.tintColor;
    
    color *= float4(tintColor.rgb, 1.0);
    
    float3 hsv = rgb2hsv(color.r, color.g, color.b);
    
    hsv[0] += uniforms.hue;
    hsv[1] *= uniforms.saturation;
    
    float3 rgb = hsv2rgb(hsv[0], hsv[1], hsv[2]);
    
    targetTexture.write(float4(rgb * tintColor.a, color.a * tintColor.a), pos);
}

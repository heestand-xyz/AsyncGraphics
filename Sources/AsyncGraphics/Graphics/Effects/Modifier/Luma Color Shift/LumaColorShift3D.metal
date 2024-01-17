//
//  Created by Anton Heestand on 2020-06-01.
//

#include <metal_stdlib>
using namespace metal;

#import "../../../../Shaders/Effects/place_header.metal"
#import "../../../../Shaders/Effects/hsv_header.metal"

struct Uniforms {
    uint placement;
    float hue;
    float saturation;
    packed_float4 tintColor;
    float lumaGamma;
};

kernel void lumaColorShift3d(const device Uniforms& uniforms [[ buffer(0) ]],
                             texture3d<float, access::write> targetTexture [[ texture(0) ]],
                             texture3d<float, access::sample> leadingTexture [[ texture(1) ]],
                             texture3d<float, access::sample> trailingTexture [[ texture(2) ]],
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
    
    float4 c = leadingTexture.sample(sampler, uvw);
   
    uint leadingWidth = leadingTexture.get_width();
    uint leadingHeight = leadingTexture.get_height();
    uint leadingDepth = leadingTexture.get_depth();
    uint trailingWidth = trailingTexture.get_width();
    uint trailingHeight = trailingTexture.get_height();
    uint trailingDepth = trailingTexture.get_depth();
    float3 uvwPlacement = place3d(uniforms.placement, uvw, leadingWidth, leadingHeight, leadingDepth, trailingWidth, trailingHeight, trailingDepth);
    
    float4 cb = trailingTexture.sample(sampler, uvwPlacement);
    float lum = (cb.r + cb.g + cb.b) / 3;
    lum = pow(lum, 1 / max(0.001, uniforms.lumaGamma));
    
    c *= float4(1.0 - ((1.0 - uniforms.tintColor.r) * lum),
                1.0 - ((1.0 - uniforms.tintColor.g) * lum),
                1.0 - ((1.0 - uniforms.tintColor.b) * lum),
                1.0);
    
    float3 hsv = rgb2hsv(c.r, c.g, c.b);
    
    hsv[0] += uniforms.hue * lum;
    hsv[1] *= 1.0 + (uniforms.saturation - 1.0) * lum;
    
    float3 cc = hsv2rgb(hsv[0], hsv[1], hsv[2]);
    
    float alpha = 1.0 - ((1.0 - uniforms.tintColor.a) * lum);
    
    float4 color = float4(cc.r * alpha, cc.g * alpha, cc.b * alpha, c.a * alpha);
    
    targetTexture.write(color, pos);
}

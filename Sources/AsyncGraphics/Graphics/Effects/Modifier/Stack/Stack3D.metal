//
//  Created by Anton Heestand on 2020-06-01.
//

#include <metal_stdlib>
using namespace metal;

struct Uniforms {
    packed_float4 backgroundColor;
    packed_float3 leadingCenter;
    packed_float3 leadingSize;
    packed_float3 trailingCenter;
    packed_float3 trailingSize;
};

kernel void stack3d(const device Uniforms& uniforms [[ buffer(0) ]],
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
    
    float3 leadingCenter = uniforms.leadingCenter;
    float3 leadingSize = uniforms.leadingSize;
    float3 trailingCenter = uniforms.trailingCenter;
    float3 trailingSize = uniforms.trailingSize;

    float4 backgroundColor = float4(uniforms.backgroundColor.rgb * uniforms.backgroundColor.a, uniforms.backgroundColor.a);
    
    float4 color = backgroundColor;
    if ((uvw.x > leadingCenter.x - leadingSize.x / 2 && uvw.x < leadingCenter.x + leadingSize.x / 2) &&
        (uvw.y > leadingCenter.y - leadingSize.y / 2 && uvw.y < leadingCenter.y + leadingSize.y / 2) &&
        (uvw.z > leadingCenter.z - leadingSize.z / 2 && uvw.z < leadingCenter.z + leadingSize.z / 2)) {
        float3 leadingOrigin = leadingCenter - leadingSize / 2;
        float3 coord = (uvw - leadingOrigin) / leadingSize;
        color = leadingTexture.sample(sampler, coord);
        
    } else if ((uvw.x > trailingCenter.x - trailingSize.x / 2 && uvw.x < trailingCenter.x + trailingSize.x / 2) &&
               (uvw.y > trailingCenter.y - trailingSize.y / 2 && uvw.y < trailingCenter.y + trailingSize.y / 2) &&
               (uvw.z > trailingCenter.z - trailingSize.z / 2 && uvw.z < trailingCenter.z + trailingSize.z / 2)) {
        float3 trailingOrigin = trailingCenter - trailingSize / 2;
        float3 coord = (uvw - trailingOrigin) / trailingSize;
        color = trailingTexture.sample(sampler, coord);
    }
    
    targetTexture.write(color, pos);
}

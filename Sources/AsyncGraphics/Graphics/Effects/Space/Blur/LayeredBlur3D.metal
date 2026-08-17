//
//  Created by Anton Heestand on 2026-08-17.
//  Copyright © 2026 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct LayeredBlur3DUniforms {
    float radius;
};

kernel void layeredBlur3d(const device LayeredBlur3DUniforms& uniforms [[ buffer(0) ]],
                          texture3d<float, access::write> targetTexture [[ texture(0) ]],
                          texture3d<float, access::sample> texture [[ texture(1) ]],
                          uint3 pos [[ thread_position_in_grid ]],
                          sampler sampler [[ sampler(0) ]]) {
    uint width = targetTexture.get_width();
    uint height = targetTexture.get_height();
    uint depth = targetTexture.get_depth();

    if (pos.x >= width || pos.y >= height || pos.z >= depth) {
        return;
    }

    float3 uvw = (float3(pos) + 0.5) / float3(width, height, depth);
    float3 aspect = float3(float(width) / float(height),
                           1.0,
                           float(depth) / float(height));
    float3 sampleStep = uniforms.radius / aspect;

    const float weights[3] = { 1.0 / 4.0, 2.0 / 4.0, 1.0 / 4.0 };
    float4 color = 0.0;

    for (int z = -1; z <= 1; ++z) {
        for (int y = -1; y <= 1; ++y) {
            for (int x = -1; x <= 1; ++x) {
                float weight = weights[x + 1] * weights[y + 1] * weights[z + 1];
                color += texture.sample(sampler, uvw + float3(x, y, z) * sampleStep) * weight;
            }
        }
    }

    targetTexture.write(color, pos);
}

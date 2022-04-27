//
//  Created by Hexagons on 2017-11-24.
//  Copyright © 2017 Hexagons. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#import "../../../../Metal/Content/noise_header.metal"
#import "../../../../Metal/Content/random_header.metal"

struct Uniforms {
    bool colored;
    bool random;
    bool includeAlpha;
    int seed;
    uint octaves;
    packed_float3 position;
    float depth;
    float zoom;
};

kernel void noise3d(const device Uniforms& uniforms [[ buffer(0) ]],
                    texture3d<float, access::write> targetTexture [[ texture(0) ]],
                    uint3 pos [[ thread_position_in_grid ]],
                    sampler s [[ sampler(0) ]]) {
    
    uint width = targetTexture.get_width();
    uint height = targetTexture.get_height();
    uint depth = targetTexture.get_depth();
    
    if (pos.x >= width || pos.y >= height || pos.z >= depth) {
        return;
    }

    float x = float(pos.x + 0.5) / float(width);
    float y = float(pos.y + 0.5) / float(height);
    float z = float(pos.z + 0.5) / float(depth);
    
    int max_res = 16384 - 1;
    
    float u = (x - uniforms.position.x - 0.5) / uniforms.zoom;
    float v = (y - uniforms.position.y - 0.5) / uniforms.zoom;
    float w = (z - uniforms.position.z - 0.5) / uniforms.zoom;
    float d = uniforms.depth;
    
    float seed = float(uniforms.seed);
    float octaves = float(uniforms.octaves);
    
    float n;
    if (uniforms.random > 0.0) {
        Loki loki_rnd = Loki(x * max_res, y * max_res, z * max_res + seed * 100);
        n = loki_rnd.rand();
    } else {
        n = octave_noise_4d(octaves, 0.5, 1.0, u, v, w, d + seed);
        n = n / 2 + 0.5;
    }
    
    float ng;
    float nb;
    if (uniforms.colored > 0.0) {
        if (uniforms.random > 0.0) {
            Loki loki_rnd_g = Loki(x * max_res, y * max_res, z * max_res + seed * 100 + 1000);
            ng = loki_rnd_g.rand();
            Loki loki_rnd_b = Loki(x * max_res, y * max_res, z * max_res + seed * 100 + 2000);
            nb = loki_rnd_b.rand();
        } else {
            ng = octave_noise_4d(octaves, 0.5, 1.0, u, v, w, d + seed + 10);
            ng = ng / 2 + 0.5;
            nb = octave_noise_4d(octaves, 0.5, 1.0, u, v, w, d + seed + 20);
            nb = nb / 2 + 0.5;
        }
    }
    
    float na;
    if (uniforms.includeAlpha > 0.0) {
        if (uniforms.random > 0.0) {
            Loki loki_rnd_g = Loki(x * max_res, y * max_res, z * max_res + seed * 100 + 3000);
            na = loki_rnd_g.rand();
        } else {
            na = octave_noise_4d(octaves, 0.5, 1.0, u, v, w, d + seed + 30);
            na = na / 2 + 0.5;
        }
    }
    
    float r = n;
    float g = uniforms.colored ? ng : n;
    float b = uniforms.colored ? nb : n;
    float a = uniforms.includeAlpha ? na : 1.0;
    
    float4 c = float4(r, g, b, a);
    
    targetTexture.write(c, pos);
}

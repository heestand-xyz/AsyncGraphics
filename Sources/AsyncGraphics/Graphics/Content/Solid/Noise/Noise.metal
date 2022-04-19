//
//  ContentGeneratorNoisePIX.metal
//  PixelKit Shaders
//
//  Created by Anton Heestand on 2017-11-24.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#import "../../../../Metal/Content/noise_header.metal"
#import "../../../../Metal/Content/random_header.metal"

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    int seed;
    uint octaves;
    packed_float3 position;
    float zoom;
    bool colored;
    bool random;
    bool includeAlpha;
    packed_float2 resolution;
};

fragment float4 noise(VertexOut out [[stage_in]],
                      const device Uniforms& uniforms [[ buffer(0) ]]) {
    
    int max_res = 16384 - 1;
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    
    float2 resolution = uniforms.resolution;
    float aspectRatio = resolution.x / resolution.y;
    
    float ux = ((u - 0.5) * aspectRatio - uniforms.position.x) / uniforms.zoom;
    float vy = ((v - 0.5) - uniforms.position.y) / uniforms.zoom;
    
    float noise;
    if (uniforms.random) {
        Loki loki_rnd = Loki(float(uniforms.seed), u * max_res, v * max_res);
        noise = loki_rnd.rand();
    } else {
        noise = octave_noise_3d(float(uniforms.octaves), 0.5, 1.0, ux, vy, uniforms.position.z + float(uniforms.seed) * 100);
        noise = noise * 0.5 + 0.5;
    }
    
    float noiseGreen;
    float noiseBlue;
    if (uniforms.colored) {
        if (uniforms.random) {
            Loki loki_rnd_g = Loki(float(uniforms.seed) + 100, u * max_res, v * max_res);
            noiseGreen = loki_rnd_g.rand();
            Loki loki_rnd_b = Loki(float(uniforms.seed) + 200, u * max_res, v * max_res);
            noiseBlue = loki_rnd_b.rand();
        } else {
            noiseGreen = octave_noise_3d(float(uniforms.octaves), 0.5, 1.0, ux, vy, uniforms.position.z + 10 + float(uniforms.seed));
            noiseGreen = noiseGreen * 0.5 + 0.5;
            noiseBlue = octave_noise_3d(float(uniforms.octaves), 0.5, 1.0, ux, vy, uniforms.position.z + 20 + float(uniforms.seed));
            noiseBlue = noiseBlue * 0.5 + 0.5;
        }
    }
    
    float noiseAlpha;
    if (uniforms.includeAlpha) {
        if (uniforms.random) {
            Loki loki_rnd_g = Loki(float(uniforms.seed) + 300, u * max_res, v * max_res);
            noiseAlpha = loki_rnd_g.rand();
        } else {
            noiseAlpha = octave_noise_3d(float(uniforms.octaves), 0.5, 1.0, ux, vy, uniforms.position.z + 30 + float(uniforms.seed));
            noiseAlpha = noiseAlpha * 0.5 + 0.5;
        }
    }
    
    float red = noise;
    float green = uniforms.colored ? noiseGreen : noise;
    float blue = uniforms.colored ? noiseBlue : noise;
    float alpha = uniforms.includeAlpha ? noiseAlpha : 1.0;
    float4 color = float4(red, green, blue, alpha);
    
    return color;
}

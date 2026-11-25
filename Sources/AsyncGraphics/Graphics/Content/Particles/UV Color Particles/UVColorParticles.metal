//
//  Created by Anton Heestand on 2019-05-02.
//  Copyright © 2019 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float pointSize [[point_size]];
    float4 color;
};

struct Uniforms {
    bool multiplyParticleSize;
    float particleScale;
    packed_float2 resolution;
};

vertex VertexOut uvColorParticles(unsigned int vid [[ vertex_id ]],
                                  const device Uniforms& uniforms [[ buffer(1) ]],
                                  texture2d<float> leadingTexture [[ texture(0) ]],
                                  texture2d<float> trailingTexture [[ texture(1) ]],
                                  sampler sampler [[ sampler(0) ]]) {
        
    uint width = leadingTexture.get_width();
    uint2 pixel = uint2(vid % width, vid / width);
    float aspectRatio = uniforms.resolution.x / uniforms.resolution.y;
    float4 uvColor = leadingTexture.read(pixel);
    float2 uv = (float2(pixel) + 0.5) / float2(width, leadingTexture.get_height());
    float4 color = trailingTexture.sample(sampler, uv);
    float x = (uvColor.r / aspectRatio) * 2;
    float y = uvColor.g * 2;
    float z = 0.0;
    
    VertexOut vtxOut;
    vtxOut.position = float4(x, y, z, 1);
    vtxOut.pointSize = uniforms.multiplyParticleSize ? uniforms.particleScale * uvColor.b : uniforms.particleScale;
    vtxOut.color = color;
    
    return vtxOut;
}

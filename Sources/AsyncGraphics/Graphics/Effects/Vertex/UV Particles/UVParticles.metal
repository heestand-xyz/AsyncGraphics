//
//  Created by Anton Heestand on 2019-05-02.
//  Copyright © 2019 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    packed_float3 position;
    packed_float2 texCoord;
};

struct VertexOut {
    float4 position [[position]];
    float pointSize [[point_size]];
    float4 color;
};

struct Uniforms {
    float particleScale;
    packed_float2 resolution;
    bool multiplyParticleSize;
    bool multiplyParticleAlpha;
    bool clipParticleAlpha;
};

vertex VertexOut uvParticles(unsigned int vid [[ vertex_id ]],
                             const device Uniforms& uniforms [[ buffer(0) ]],
                             texture2d<float> texture [[ texture(0) ]],
                             sampler sampler [[ sampler(0) ]]) {
    
    float width = uniforms.resolution.x;
    float height = uniforms.resolution.y;
    float aspectRatio = width / height;
    
    int ux = vid % int(width);
    int vy = int(float(vid) / width);
    float u = float(ux) / width;
    float v = float(vy) / height;
    float2 uv = float2(u, v);
    
    float4 uvColor = texture.sample(sampler, uv);
    float x = (uvColor.r / aspectRatio) * 2;
    float y = uvColor.g * 2;
    float z = 0.0;
    
    VertexOut vtxOut;
    vtxOut.position = float4(x, y, z, 1);
    vtxOut.pointSize = uniforms.multiplyParticleSize ? uniforms.particleScale * uvColor.b : uniforms.particleScale;
    vtxOut.color = uniforms.multiplyParticleAlpha ? float4(float3(1.0), uniforms.clipParticleAlpha ? uvColor.a == 1.0 : uvColor.a) : float4(1.0);
    
    return vtxOut;
}

////
////  Created by Anton Heestand on 2023-12-03.
////  Copyright © 2023 Anton Heestand. All rights reserved.
////
//
//#include <metal_stdlib>
//using namespace metal;
//
//struct Uniforms {
//    bool multiplyParticleAlpha;
//    bool clipParticleAlpha;
//    float particleScale;
//    packed_float3 resolution;
//};
//
//kernel void uvwParticles(const device Uniforms& uniforms [[ buffer(0) ]],
//                         texture3d<float, access::write>  targetTexture [[ texture(0) ]],
//                         texture3d<float, access::sample> texture [[ texture(1) ]],
//                         const device array<ColorStopArray, ARRMAX>& colorStops [[ buffer(1) ]],
//                         const device array<bool, ARRMAX>& actives [[ buffer(2) ]],
//                         uint3 pos [[ thread_position_in_grid ]],
//                         sampler s [[ sampler(0) ]]) {
//    
//    float width = uniforms.resolution.x;
//    float height = uniforms.resolution.y;
//    float depth = uniforms.resolution.z;
//    float aspectRatio = width / height;
//    float depthAspectRatio = depth / height;
//    
//    int ux = vid % int(width);
//    int vy = (vid / int(width)) % int(height);
//    int wz = int(float(vid) / (width * height));
//    
//    float u = (float(ux) + 0.5) / width;
//    float v = (float(vy) + 0.5) / height;
//    float w = (float(wz) + 0.5) / depth;
//    float3 uvw = float3(u, v, w);
//    
//    float4 uvwColor = texture.sample(sampler, uvw);
//    float x = (uvwColor.x / aspectRatio) * 2;
//    float y = uvwColor.y * 2;
//    float z = (uvwColor.z / depthAspectRatio) * 2;
//    
//    VertexOut vtxOut;
//    vtxOut.position = float4(x, y, z, 1);
//    vtxOut.pointSize = uniforms.particleScale;
//    vtxOut.color = uniforms.multiplyParticleAlpha ? float4(float3(1.0), uniforms.clipParticleAlpha ? uvwColor.a == 1.0 : uvwColor.a) : float4(1.0);
//    
//    return vtxOut;
//}

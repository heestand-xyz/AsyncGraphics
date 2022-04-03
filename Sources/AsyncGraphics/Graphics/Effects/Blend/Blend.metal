//
//  EffectMergerBlendPIX.metal
//  PixelKitShaders
//
//  Created by Anton Heestand on 2017-11-10.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#import "../../../Metal/Effects/place_header.metal"
#import "../../../Metal/Effects/blend_header.metal"

struct VertexOut{
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms{
    int mode;
    int place;
};

fragment float4 blend(VertexOut out [[stage_in]],
                      texture2d<float>  inTexA [[ texture(0) ]],
                      texture2d<float>  inTexB [[ texture(1) ]],
                      const device Uniforms& in [[ buffer(0) ]],
                      sampler s [[ sampler(0) ]]) {
    
    float pi = M_PI_F;
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    uint w = inTexB.get_width();
    uint h = inTexB.get_height();
    float aspect = float(w) / float(h);
        
    float4 ca = inTexA.sample(s, uv);
    
    uint aw = inTexA.get_width();
    uint ah = inTexA.get_height();
    uint bw = inTexB.get_width();
    uint bh = inTexB.get_height();
    float2 uvp = place(in.place, uv, aw, ah, bw, bh);
    
    float4 cb = inTexB.sample(s, uvp);
    
    float4 c = blend(in.mode, ca, cb);
    
    return c;
}

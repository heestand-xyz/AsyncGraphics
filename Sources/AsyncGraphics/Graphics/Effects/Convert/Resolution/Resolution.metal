//
//  Created by Anton Heestand on 2018-01-15.
//  Open Source - MIT License
//

#include <metal_stdlib>
using namespace metal;

#import "../../../../Shaders/Effects/place_header.metal"

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    int placement;
    packed_float2 outputResolution;
};

fragment float4 resolution(VertexOut out [[stage_in]],
                           texture2d<float> texture [[ texture(0) ]],
                           const device Uniforms& uniforms [[ buffer(0) ]],
                           sampler sampler [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    uint inputWidth = texture.get_width();
    uint inputHeight = texture.get_height();
    uint outputWidth = uint(uniforms.outputResolution.x);
    uint outputHeight = uint(uniforms.outputResolution.y);
    
    float2 uvPlacement = place(uniforms.placement, uv, outputWidth, outputHeight, inputWidth, inputHeight);

    float4 color = texture.sample(sampler, uvPlacement);
    
    return color;
}

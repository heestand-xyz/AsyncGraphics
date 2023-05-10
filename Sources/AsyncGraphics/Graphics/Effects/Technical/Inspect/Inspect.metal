//
//  Created by Anton Heestand on 2023-05-10.
//  AsyncGraphics
//

#include <metal_stdlib>
using namespace metal;

#import "../../../../Metal/Effects/place_header.metal"

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    float scale;
    packed_float2 offset;
    float borderWidth;
    packed_float4 borderColor;
    uint placement;
    packed_float2 resolution;
};

fragment float4 inspect(VertexOut out [[stage_in]],
                        texture2d<float> texture [[ texture(0) ]],
                        const device Uniforms& uniforms [[ buffer(0) ]],
                        sampler sampler [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    uint inputWidth = texture.get_width();
    uint inputHeight = texture.get_height();
    float inputAspect = float(inputWidth) / float(inputHeight);
    uint outputWidth = uniforms.resolution.x;
    uint outputHeight = uniforms.resolution.y;
    float outputAspect = float(outputWidth) / float(outputHeight);
    
    float2 uvPlacement = place(uniforms.placement, uv, outputWidth, outputHeight, inputWidth, inputHeight);
    
    float2 uvScale = float2(uniforms.scale, uniforms.scale);
    uvPlacement = (uvPlacement - 0.5) / uvScale + 0.5;
    uvPlacement -= uniforms.offset / uniforms.resolution;

    float4 color = texture.sample(sampler, uvPlacement);
    
    return color;
}

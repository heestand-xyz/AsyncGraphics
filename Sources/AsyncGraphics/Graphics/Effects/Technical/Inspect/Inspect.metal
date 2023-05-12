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
    float borderOpacity;
    uint placement;
    packed_float2 scaleRange;
    packed_float2 resolution;
};

fragment float4 inspect(VertexOut out [[stage_in]],
                        texture2d<float> texture [[ texture(0) ]],
                        const device Uniforms& uniforms [[ buffer(0) ]],
                        sampler sampler [[ sampler(0) ]]) {
    
    // Coordinates
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    // Resolution
    uint inputWidth = texture.get_width();
    uint inputHeight = texture.get_height();
    uint outputWidth = uniforms.resolution.x;
    uint outputHeight = uniforms.resolution.y;
    
    // Placement
    float2 uvPlacement = place(uniforms.placement, uv, outputWidth, outputHeight, inputWidth, inputHeight);
    float2 uvScale = float2(uniforms.scale, uniforms.scale);
    uvPlacement = (uvPlacement - 0.5) / uvScale + 0.5;
    uvPlacement -= uniforms.offset / uniforms.resolution;

    // Texture
    float4 color = texture.sample(sampler, uvPlacement);
    
    // Border
    if (uniforms.scale >= uniforms.scaleRange.x && uniforms.borderOpacity > 0.0 && uniforms.borderWidth > 0.0) {
        float fraction = (uniforms.scale - uniforms.scaleRange.x) / (uniforms.scaleRange.y - uniforms.scaleRange.x);
        float zoomFade = min(max(fraction, 0.0), 1.0);
        float2 uvBorder = float2(uniforms.borderWidth / uniforms.scale,
                                 uniforms.borderWidth / uniforms.scale);
        float2 uvResolution = float2(uvPlacement.x * float(inputWidth),
                                     uvPlacement.y * float(inputHeight));
        float2 uvPixel = float2(uvResolution.x - float(int(uvResolution.x)),
                                uvResolution.y - float(int(uvResolution.y)));
        if (!(uvPixel.x > uvBorder.x && uvPixel.x < 1.0 - uvBorder.x) || !(uvPixel.y > uvBorder.y && uvPixel.y < 1.0 - uvBorder.y)) {
            float brightness = (color.r + color.g + color.b) / 3;
            float4 borderColor = float4(float3(brightness < 0.5 ? 1.0 : 0.0), uniforms.borderOpacity * zoomFade);
            color = float4(color.rgb * (1.0 - borderColor.a) + borderColor.rgb * borderColor.a, max(color.a, borderColor.a));
        }
    }
    
    return color;
}

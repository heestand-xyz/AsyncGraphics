//
//  Created by Anton Heestand on 2015-01-10.
//  Copyright © 2025 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    float4 seedColor;
    float4 foregroundColor;
    float4 backgroundColor;
    float2 resolution;
    float threshold;
    float stepDistance;
};

fragment float4 floodFill(VertexOut out [[stage_in]],
                          texture2d<float> leadingTexture [[ texture(0) ]],
                          texture2d<float> trailingTexture [[ texture(1) ]],
                          const device Uniforms& uniforms [[ buffer(0) ]],
                          sampler sampler [[ sampler(0) ]]) {
    float2 uv = out.texCoord;
    
    float4 sourceColor = leadingTexture.sample(sampler, uv);
    
    float4 maskColor = trailingTexture.sample(sampler, uv);
    if (maskColor.r > 0.5) {
        return float4(1.0);
    }
    
    float stepDistance = uniforms.stepDistance;
    float2 resolution = uniforms.resolution;
    
    float4 maskUpColor = trailingTexture.sample(sampler, uv + float2(0.0,  1.0 / resolution.y) * stepDistance);
    float4 maskDownColor = trailingTexture.sample(sampler, uv + float2(0.0, -1.0 / resolution.y) * stepDistance);
    float4 maskLeftColor = trailingTexture.sample(sampler, uv + float2(-1.0 / resolution.x,  0.0) * stepDistance);
    float4 maskRightColor = trailingTexture.sample(sampler, uv + float2( 1.0 / resolution.x,  0.0) * stepDistance);
    
    float4 upColor = leadingTexture.sample(sampler, uv + float2(0.0,  1.0 / resolution.y) * stepDistance);
    float4 downColor = leadingTexture.sample(sampler, uv + float2(0.0, -1.0 / resolution.y) * stepDistance);
    float4 leftColor = leadingTexture.sample(sampler, uv + float2(-1.0 / resolution.x,  0.0) * stepDistance);
    float4 rightColor = leadingTexture.sample(sampler, uv + float2( 1.0 / resolution.x,  0.0) * stepDistance);
    
    bool isUpFilled   = (maskUpColor.r   > 0.5) && (distance(upColor,   sourceColor) < uniforms.threshold);
    bool isDownFilled = (maskDownColor.r > 0.5) && (distance(downColor, sourceColor) < uniforms.threshold);
    bool isLeftFilled = (maskLeftColor.r > 0.5) && (distance(leftColor, sourceColor) < uniforms.threshold);
    bool isRightFilled= (maskRightColor.r> 0.5) && (distance(rightColor,sourceColor) < uniforms.threshold);
    
    if (isUpFilled || isDownFilled || isLeftFilled || isRightFilled) {
        return float4(1.0);
    }
    
    return float4(0.0);
}

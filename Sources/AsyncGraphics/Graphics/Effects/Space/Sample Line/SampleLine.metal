//
//  Created by Anton Heestand on 2017-11-21.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
#import "../../../../Shaders/Effects/blend_header.metal"

using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    float sampleDistance;
    packed_float2 leadingPoint;
    packed_float2 trailingPoint;
    float leadingAngle;
    float trailingAngle;
    packed_float4 backgroundColor;
    uint blendingMode;
    packed_float2 resolution;
};

fragment float4 sampleLine(VertexOut out [[stage_in]],
                           texture2d<float> texture [[ texture(0) ]],
                           const device Uniforms& uniforms [[ buffer(0) ]],
                           sampler sampler [[ sampler(0) ]]) {
    
    float2 resolution = uniforms.resolution;
    float2 sampleResolution = float2(texture.get_width(), texture.get_height());
    float aspectRatio = resolution.x / resolution.y;
    float sampleAspectRatio = sampleResolution.x / sampleResolution.y;
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    float2 point = (uv - 0.5) * float2(aspectRatio, 1.0);
    float2 leadingPoint = uniforms.leadingPoint;
    float2 trailingPoint = uniforms.trailingPoint;
    
    float distance = sqrt(pow(trailingPoint.x - leadingPoint.x, 2) +
                          pow(trailingPoint.y - leadingPoint.y, 2));
    
    float leadingAngle = uniforms.leadingAngle;
    float trailingAngle = uniforms.trailingAngle;
    float angle = atan2(trailingPoint.y - leadingPoint.y,
                        trailingPoint.x - leadingPoint.x);
    
    int count = int(distance / uniforms.sampleDistance) + 1;
    
    float4 color = uniforms.backgroundColor;
    
    float scale = sampleResolution.y / resolution.y;
    
    for (int i = 0; i < count; i++) {
        
        float offset = float(i) * uniforms.sampleDistance;
        float fraction = offset / distance;
        
        float2 vector = float2(cos(angle) * offset,
                               sin(angle) * offset);
        
        float2 samplePoint = (point - leadingPoint - vector) / scale;
        
        float rotation = leadingAngle * (1.0 - fraction) + trailingAngle * fraction;
        
        float sampleRadius = sqrt(pow(samplePoint.x, 2) + pow(samplePoint.y, 2));
        float sampleAngle = atan2(samplePoint.y, samplePoint.x);
        sampleAngle -= rotation;
        samplePoint = float2(cos(sampleAngle) * sampleRadius,
                             sin(sampleAngle) * sampleRadius);
        
        
        float2 sampleUV = samplePoint / float2(sampleAspectRatio, 1.0) + 0.5;
        
        float4 sampleColor = texture.sample(sampler, sampleUV);
        
        color = blend(uniforms.blendingMode, color, sampleColor);
    }
    
    return color;
}



//
//  Created by Anton Heestand on 2017-11-17.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    float radius;
    packed_float2 position;
    float edgeRadius;
    packed_float4 foregroundColor;
    packed_float4 edgeColor;
    packed_float4 backgroundColor;
    bool premultiply;
    packed_float2 resolution;
    float aspectRatio;
};

fragment float4 circle(VertexOut out [[stage_in]],
                       const device Uniforms& uniforms [[ buffer(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float onePixel = 1.0 / max(uniforms.resolution.x, uniforms.resolution.y);
    
    float4 foregroundColor = uniforms.foregroundColor;
    float4 edgeColor = uniforms.edgeColor;
    float4 backgroundColor = uniforms.backgroundColor;
    
    float4 color = backgroundColor;
        
    float edgeRadius = uniforms.edgeRadius;
    if (edgeRadius < 0.0) {
        edgeRadius = 0.0;
    }
            
    float radius = sqrt(pow((u - 0.5) * uniforms.aspectRatio - uniforms.position.x, 2) + pow(v - 0.5 - uniforms.position.y, 2));
    
    if (edgeRadius > 0.0) {
        if (radius < uniforms.radius - edgeRadius / 2 - onePixel / 2) {
            color = foregroundColor;
        } else if (radius < uniforms.radius - edgeRadius / 2 + onePixel / 2) {
            float fraction = (radius - (uniforms.radius - edgeRadius / 2 - onePixel / 2)) / onePixel;
            color = foregroundColor * (1.0 - fraction) + edgeColor * fraction;
        } else if (radius < uniforms.radius + edgeRadius / 2 - onePixel / 2) {
            color = edgeColor;
        } else if (radius < uniforms.radius + edgeRadius / 2 + onePixel / 2) {
            float fraction = (radius - (uniforms.radius + edgeRadius / 2 - onePixel / 2)) / onePixel;
            color = edgeColor * (1.0 - fraction) + backgroundColor * fraction;
        }
    } else {
        if (radius < uniforms.radius - onePixel / 2) {
            color = foregroundColor;
        } else if (radius < uniforms.radius + onePixel / 2) {
            float fraction = (radius - (uniforms.radius - onePixel / 2)) / onePixel;
            color = foregroundColor * (1.0 - fraction) + backgroundColor * fraction;
        }
    }
    
    if (uniforms.premultiply) {
        color = float4(color.rgb * color.a, color.a);
    }
    
    return color;
}

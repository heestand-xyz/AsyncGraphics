//
//  Created by Anton Heestand on 2017-11-17.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#import "../../../../Metal/Content/radius_header.metal"

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    bool premultiply;
    bool antiAlias;
    float radius;
    packed_float2 position;
    float edgeRadius;
    packed_float4 foregroundColor;
    packed_float4 edgeColor;
    packed_float4 backgroundColor;
    packed_float2 resolution;
};

fragment float4 circle(VertexOut out [[stage_in]],
                       const device Uniforms& uniforms [[ buffer(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];

    float onePixel = 1.0 / max(uniforms.resolution.x, uniforms.resolution.y);
    
    float4 foregroundColor = uniforms.foregroundColor;
    float4 edgeColor = uniforms.edgeColor;
    float4 backgroundColor = uniforms.backgroundColor;
    
    float edgeRadius = max(uniforms.edgeRadius, 0.0);
    
    float aspectRatio = uniforms.resolution.x / uniforms.resolution.y;
            
    float xRadius = (u - 0.5) * aspectRatio - uniforms.position.x;
    float yRadius = v - 0.5 - uniforms.position.y;
    float radius = sqrt(pow(xRadius, 2) + pow(yRadius, 2));
    
    float4 color = radiusColor(radius, uniforms.radius, edgeRadius, foregroundColor, edgeColor, backgroundColor, uniforms.antiAlias, onePixel);
    
    if (uniforms.premultiply) {
        color = float4(color.rgb * color.a, color.a);
    }
    
    return color;
}

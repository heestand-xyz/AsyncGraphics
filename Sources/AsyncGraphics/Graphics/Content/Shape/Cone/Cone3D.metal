//
//  Created by Anton Heestand on 2023-11-26.
//  Copyright © 2023 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#import "../../../../Shaders/Content/radius_header.metal"

struct Uniforms {
    uint axis;
    bool premultiply;
    bool antiAlias;
    float leadingRadius;
    float trailingRadius;
    float length;
    packed_float3 position;
    float surfaceWidth;
    packed_float4 foregroundColor;
    packed_float4 edgeColor;
    packed_float4 backgroundColor;
};

kernel void cone3d(const device Uniforms& uniforms [[ buffer(0) ]],
                   texture3d<float, access::write> targetTexture [[ texture(0) ]],
                   uint3 pos [[ thread_position_in_grid ]]) {

    uint width = targetTexture.get_width();
    uint height = targetTexture.get_height();
    uint depth = targetTexture.get_depth();
    
    if (pos.x >= width || pos.y >= height || pos.z >= depth) {
        return;
    }

    float onePixel = 1.0 / float(max(max(width, height), depth));

    float u = float(pos.x + 0.5) / float(width);
    float v = float(pos.y + 0.5) / float(height);
    float w = float(pos.z + 0.5) / float(depth);
    
    float4 foregroundColor = uniforms.foregroundColor;
    float4 edgeColor = uniforms.edgeColor;
    float4 backgroundColor = uniforms.backgroundColor;
        
    float surfaceWidth = max(0.0, uniforms.surfaceWidth);
    float leadingRadius = max(0.0, uniforms.leadingRadius);
    float trailingRadius = max(0.0, uniforms.trailingRadius);
    float length = max(0.0, uniforms.length);
    
    float aspectRatio = float(width) / float(height);
    float depthAspectRatio = float(depth) / float(height);
    
    float x = (u - 0.5) * aspectRatio - uniforms.position.x;
    float y = (v - 0.5) - uniforms.position.y;
    float z = (w - 0.5) * depthAspectRatio - uniforms.position.z;
    float radialRadius = 0.0;
    float direction = 0.0;
    switch (uniforms.axis) {
        case 0: // x
            radialRadius = sqrt(pow(z, 2) + pow(y, 2));
            direction = x;
            break;
        case 1: // y
            radialRadius = sqrt(pow(x, 2) + pow(z, 2));
            direction = y;
            break;
        case 2: // z
            radialRadius = sqrt(pow(x, 2) + pow(y, 2));
            direction = z;
            break;
    }
    float value = radialRadius;
    float fraction = direction / length + length / 2;
    float4 color = 0.0;
    if (fraction >= 0.0 && fraction <= 1.0) {
        float radius = mix(leadingRadius, trailingRadius, fraction);
        color = radiusColor(value, radius, surfaceWidth, foregroundColor, edgeColor, backgroundColor, uniforms.antiAlias, uniforms.premultiply, onePixel);
    }
    
    if (uniforms.premultiply) {
        color = float4(color.rgb * color.a, color.a);
    }
    
    targetTexture.write(color, pos);
}

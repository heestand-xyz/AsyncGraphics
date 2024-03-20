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
    float radius;
    float length;
    float cornerRadius;
    packed_float3 position;
    float surfaceWidth;
    packed_float4 foregroundColor;
    packed_float4 edgeColor;
    packed_float4 backgroundColor;
    packed_float3 tileOrigin;
    packed_float3 tileSize;
};

kernel void cylinder3d(const device Uniforms& uniforms [[ buffer(0) ]],
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
    u = u * uniforms.tileSize.x + uniforms.tileOrigin.x;
    v = v * uniforms.tileSize.y + uniforms.tileOrigin.y;
    w = w * uniforms.tileSize.z + uniforms.tileOrigin.z;
    
    float4 foregroundColor = uniforms.foregroundColor;
    float4 edgeColor = uniforms.edgeColor;
    float4 backgroundColor = uniforms.backgroundColor;
        
    float surfaceWidth = uniforms.surfaceWidth;
    if (surfaceWidth < 0) {
        surfaceWidth = 0;
    }
    
    float cornerRadius = uniforms.cornerRadius;
    if (cornerRadius < 0) {
        cornerRadius = 0;
    }
    
    float radius = uniforms.radius;
    if (radius < 0) {
        radius = 0;
    }
    
    float length = uniforms.length;
    if (length < 0) {
        length = 0;
    }
    
    float aspectRatio = float(width) / float(height);
    float depthAspectRatio = float(depth) / float(height);
    
    float x = (u - 0.5) * aspectRatio - uniforms.position.x;
    float y = (v - 0.5) - uniforms.position.y;
    float z = (w - 0.5) * depthAspectRatio - uniforms.position.z;
    float radialRadius = 0.0;
    float lengthRadius = 0.0;
    switch (uniforms.axis) {
        case 0: // x
            radialRadius = sqrt(pow(z, 2) + pow(y, 2));
            lengthRadius = abs(x);
            break;
        case 1: // y
            radialRadius = sqrt(pow(x, 2) + pow(z, 2));
            lengthRadius = abs(y);
            break;
        case 2: // z
            radialRadius = sqrt(pow(x, 2) + pow(y, 2));
            lengthRadius = abs(z);
            break;
    }
    float value;
    float angle = atan2(radialRadius - radius, lengthRadius - length / 2);
    if (angle + M_PI_F < M_PI_F / 4 || angle - M_PI_F / 2 > -M_PI_F / 4) {
        value = radialRadius;
    } else {
        value = lengthRadius - length / 2 + radius;
    }
    if (cornerRadius > 0.0 &&
        radialRadius > radius - cornerRadius &&
        lengthRadius > length / 2 - cornerRadius) {
        value = sqrt(pow(radialRadius - radius + cornerRadius, 2) +
                     pow(lengthRadius - length / 2 + cornerRadius, 2)) + radius - cornerRadius;
    }
    
    float4 color = radiusColor(value, radius, surfaceWidth, foregroundColor, edgeColor, backgroundColor, uniforms.antiAlias, uniforms.premultiply, onePixel);
    
    if (uniforms.premultiply) {
        color = float4(color.rgb * color.a, color.a);
    }
    
    targetTexture.write(color, pos);
}

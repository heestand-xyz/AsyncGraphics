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
    float revolvingRadius;
    packed_float3 position;
    float surfaceWidth;
    packed_float4 foregroundColor;
    packed_float4 edgeColor;
    packed_float4 backgroundColor;
    packed_float3 tileOrigin;
    packed_float3 tileSize;
};

kernel void torus3d(const device Uniforms& uniforms [[ buffer(0) ]],
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
    
    float radius = uniforms.radius;
    if (radius < 0) {
        radius = 0;
    }
    
    float revolvingRadius = uniforms.revolvingRadius;
    if (revolvingRadius < 0) {
        revolvingRadius = 0;
    }
    
    float aspectRatio = float(width) / float(height);
    float depthAspectRatio = float(depth) / float(height);
    
    float x = (u - 0.5) * aspectRatio - uniforms.position.x;
    float y = (v - 0.5) - uniforms.position.y;
    float z = (w - 0.5) * depthAspectRatio - uniforms.position.z;
    float value;
    switch (uniforms.axis) {
        case 0: // x
            value = sqrt(pow(sqrt(pow(z, 2) + pow(y, 2)) - radius, 2) +
                         pow(x, 2));
            break;
        case 1: // y
            value = sqrt(pow(sqrt(pow(x, 2) + pow(z, 2)) - radius, 2) +
                         pow(y, 2));
            break;
        case 2: // z
            value = sqrt(pow(sqrt(pow(x, 2) + pow(y, 2)) - radius, 2) +
                         pow(z, 2));
            break;
    }
    
    float4 color = radiusColor(value, revolvingRadius, surfaceWidth, foregroundColor, edgeColor, backgroundColor, uniforms.antiAlias, uniforms.premultiply, onePixel);
    
    if (uniforms.premultiply) {
        color = float4(color.rgb * color.a, color.a);
    }
    
    targetTexture.write(color, pos);
}

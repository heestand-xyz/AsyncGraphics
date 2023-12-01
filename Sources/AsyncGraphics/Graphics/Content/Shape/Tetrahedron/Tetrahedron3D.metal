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
    packed_float3 position;
    float surfaceWidth;
    packed_float4 foregroundColor;
    packed_float4 edgeColor;
    packed_float4 backgroundColor;
};

float plane(float3 p, float3 c, float3 n) {
     return dot(p - c, n);
}

float tetrahedron(float3 p, float e) {
    float f = sqrt(1.0 / 3.0);
    float a = plane(p, float3(e, e, e), float3(-f, f, f));
    float b = plane(p, float3(e, -e, -e), float3(f, -f, f));
    float c = plane(p, float3(-e, e, -e), float3(f, f, -f));
    float d = plane(p, float3(-e, -e, e), float3(-f, -f, -f));
    return max(max(a, b), max(c, d));
}

kernel void tetrahedron3d(const device Uniforms& uniforms [[ buffer(0) ]],
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
    float radius = max(0.0, uniforms.radius);
    
    float aspectRatio = float(width) / float(height);
    float depthAspectRatio = float(depth) / float(height);
    
    float x = (u - 0.5) * aspectRatio - uniforms.position.x;
    float y = (v - 0.5) - uniforms.position.y;
    float z = (w - 0.5) * depthAspectRatio - uniforms.position.z;
//    switch (uniforms.axis) {
//        case 0: // x
//            break;
//        case 1: // y
//            break;
//        case 2: // z
//            break;
//    }
    
    float3 point = float3(x, y, z);
    float value = tetrahedron(point, radius);

    float4 color = radiusColor(value, 0.0, surfaceWidth, foregroundColor, edgeColor, backgroundColor, uniforms.antiAlias, uniforms.premultiply, onePixel);
    
    if (uniforms.premultiply) {
        color = float4(color.rgb * color.a, color.a);
    }
    
    targetTexture.write(color, pos);
}

//
//  Created by Anton Heestand on 2017-11-17.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#import "../../../../Metal/Content/radius_header.metal"

struct Uniforms {
    bool premultiply;
    bool antiAlias;
    float radius;
    packed_float3 position;
    float edgeRadius;
    packed_float4 foregroundColor;
    packed_float4 edgeColor;
    packed_float4 backgroundColor;
};

kernel void sphere3d(const device Uniforms& uniforms [[ buffer(0) ]],
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
        
    float edgeRadius = uniforms.edgeRadius;
    if (edgeRadius < 0) {
        edgeRadius = 0;
    }
    
    float aspectRatio = float(width) / float(height);
    float depthAspectRatio = float(depth) / float(height);
    
    float xRadius = (u - 0.5) * aspectRatio - uniforms.position.x;
    float yRadius = (v - 0.5) - uniforms.position.y;
    float zRadius = (w - 0.5) * depthAspectRatio - uniforms.position.z;
    float radius = sqrt(pow(sqrt(pow(xRadius, 2) + pow(yRadius, 2)), 2) + pow(zRadius, 2));
    
    float4 color = radiusColor(radius, uniforms.radius, edgeRadius, foregroundColor, edgeColor, backgroundColor, uniforms.antiAlias, uniforms.premultiply, onePixel);
    
    if (uniforms.premultiply) {
        color = float4(color.rgb * color.a, color.a);
    }
    
    targetTexture.write(color, pos);
}

//
//  Created by Anton Heestand on 2017-11-17.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#import "../../../../Metal/Content/radius_header.metal"

struct Uniforms {
    bool premultiply;
    bool antiAliasing;
    float radius;
    packed_float3 position;
    float edgeRadius;
    packed_float4 foregroundColor;
    packed_float4 edgeColor;
    packed_float4 backgroundColor;
};

kernel void sphere3d(const device Uniforms& uniforms [[ buffer(0) ]],
                     texture3d<float, access::write> targetTexture [[ texture(0) ]],
                     uint3 pos [[ thread_position_in_grid ]],
                     sampler s [[ sampler(0) ]]) {

    if (pos.x >= targetTexture.get_width()) {
        return;
    } else if (pos.y >= targetTexture.get_height()) {
        return;
    } else if (pos.z >= targetTexture.get_depth()) {
        return;
    }

    uint width = targetTexture.get_width();
    uint height = targetTexture.get_height();
    uint depth = targetTexture.get_depth();

    float onePixel = 1.0 / float(max(max(width, height), depth));

    float x = float(pos.x + 0.5) / float(width);
    float y = float(pos.y + 0.5) / float(height);
    float z = float(pos.z + 0.5) / float(depth);
    
    float4 foregroundColor = uniforms.foregroundColor;
    float4 edgeColor = uniforms.edgeColor;
    float4 backgroundColor = uniforms.backgroundColor;
        
    float edgeRadius = uniforms.edgeRadius;
    if (edgeRadius < 0) {
        edgeRadius = 0;
    }
    
    float aspectRatio = float(width) / float(height);
    float depthAspectRatio = float(depth) / float(height);
    
    float xRadius = (x - 0.5) * aspectRatio - uniforms.position.x;
    float yRadius = y - 0.5 - uniforms.position.y;
    float zRadius = (z - 0.5) * depthAspectRatio - uniforms.position.z;
    float radius = sqrt(pow(sqrt(pow(xRadius, 2) + pow(yRadius, 2)), 2) + pow(zRadius, 2));
    
    float4 color = radiusColor(radius, uniforms.radius, edgeRadius, foregroundColor, edgeColor, backgroundColor, uniforms.antiAliasing, onePixel);
    
    if (uniforms.premultiply) {
        color = float4(color.rgb * color.a, color.a);
    }
    
    targetTexture.write(color, pos);
}

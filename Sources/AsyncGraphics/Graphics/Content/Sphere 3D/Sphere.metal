//
//  Created by Anton Heestand on 2017-11-17.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct Uniforms {
    bool premultiply;
    float radius;
    packed_float3 position;
    float edgeRadius;
    packed_float4 foregroundColor;
    packed_float4 edgeColor;
    packed_float4 backgroundColor;
};

kernel void sphere(const device Uniforms& uniforms [[ buffer(0) ]],
                   texture3d<float, access::write> targetTexture [[ texture(0) ]],
                   uint3 pos [[ thread_position_in_grid ]],
                   sampler s [[ sampler(0) ]]) {
    
    if (pos.x >= targetTexture.get_width() || pos.y >= targetTexture.get_height() || pos.z >= targetTexture.get_depth()) {
        return;
    }
    
    float x = float(pos.x + 0.5) / float(targetTexture.get_width());
    float y = float(pos.y + 0.5) / float(targetTexture.get_height());
    float z = float(pos.z + 0.5) / float(targetTexture.get_depth());
    
    float4 foregroundColor = uniforms.foregroundColor;
    float4 edgeColor = uniforms.edgeColor;
    float4 backgroundColor = uniforms.backgroundColor;
    
    float4 color = backgroundColor;
    
    float edgeRadius = uniforms.edgeRadius;
    if (edgeRadius < 0) {
        edgeRadius = 0;
    }
    
    // TODO: Pixel Smoothing
    
    // TODO: Aspect Ratio
    
    float dist = sqrt(pow(sqrt(pow(x - 0.5 - uniforms.position.x, 2) + pow(y - 0.5 - uniforms.position.y, 2)), 2) + pow(z - 0.5 - uniforms.position.z, 2));
    if (dist < uniforms.radius - edgeRadius / 2) {
        color = foregroundColor;
    } else if (dist < uniforms.radius + edgeRadius / 2) {
        color = edgeColor;
    }
    
    if (uniforms.premultiply) {
        color = float4(color.rgb * color.a, color.a);
    }
    
    targetTexture.write(color, pos);
}

//
//  Created by Anton Heestand on 2017-11-21.
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
    float width;
    float leadingAngle;
    float trailingAngle;
};

fragment float4 polar(VertexOut out [[stage_in]],
                     texture2d<float>  texture [[ texture(0) ]],
                     const device Uniforms& uniforms [[ buffer(0) ]],
                     sampler sampler [[ sampler(0) ]]) {

    float pi = M_PI_F;
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    float radius = sqrt(pow(uv.x - 0.5, 2) + pow(uv.y - 0.5, 2)) / 2 + 0.25;
    
    radius -= uniforms.radius - uniforms.width / 2;
    radius /= uniforms.width;
    
    float angle = atan2(uv.y - 0.5, uv.x - 0.5) / (pi * 2);
    if (angle < 0.0) {
        angle += 1.0;
    } else if (angle > 1.0) {
        angle -= 1.0;
    }
    
    angle -= uniforms.leadingAngle;
    angle /= uniforms.trailingAngle - uniforms.leadingAngle;
    
    if (angle >= 0.0 && angle <= 1.0) {
        
        float2 uvPolar = float2(angle, radius);
        
        float4 color = texture.sample(sampler, uvPolar);
        
        return color;
        
    } else {
    
        return 0.0;
    }
}

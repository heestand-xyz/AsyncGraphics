//
//  Created by Anton Heestand on 2017-11-10.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#import "../../../../Metal/Effects/blend_header.metal"
#import "../../../../Metal/Effects/place_header.metal"

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    bool transform;
    int blendingMode;
    int placement;
    packed_float2 translation;
    float rotation;
    float scale;
    packed_float2 size;
};

fragment float4 blend(VertexOut out [[stage_in]],
                      texture2d<float> leadingTexture [[ texture(0) ]],
                      texture2d<float> trailingTexture [[ texture(1) ]],
                      const device Uniforms& uniforms [[ buffer(0) ]],
                      sampler sampler [[ sampler(0) ]]) {
    
    float pi = M_PI_F;

    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    float4 leadingColor = leadingTexture.sample(sampler, uv);
    
    uint leadingWidth = leadingTexture.get_width();
    uint leadingHeight = leadingTexture.get_height();
    uint trailingWidth = trailingTexture.get_width();
    uint trailingHeight = trailingTexture.get_height();
    float aspectRatio = float(trailingWidth) / float(trailingHeight);
    float2 uvPlacement = place(uniforms.placement, uv, leadingWidth, leadingHeight, trailingWidth, trailingHeight);
    float unitPlacement = unitPlace(uniforms.placement, leadingWidth, leadingHeight, trailingWidth, trailingHeight);

    float4 trailingColor;
    
    if (uniforms.transform) {
        float2 size = float2(uniforms.size.x * uniforms.scale, uniforms.size.y * uniforms.scale);
        float x = (uvPlacement.x - 0.5) * aspectRatio - uniforms.translation.x * unitPlacement;
        float y = uvPlacement.y - 0.5 - uniforms.translation.y * unitPlacement;
        float angle = atan2(y, x) - (uniforms.rotation * pi * 2);
        float radius = sqrt(pow(x, 2) + pow(y, 2));
        float2 uvTransform = float2((cos(angle) / aspectRatio) * radius,
                                    sin(angle) * radius) / size + 0.5;
        trailingColor = trailingTexture.sample(sampler, uvTransform);
    } else {
        trailingColor = trailingTexture.sample(sampler, uvPlacement);
    }
    
    float4 color = blend(uniforms.blendingMode, leadingColor, trailingColor);
    
    return color;
}

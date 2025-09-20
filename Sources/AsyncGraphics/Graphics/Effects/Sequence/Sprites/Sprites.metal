//
//  Created by Anton Heestand on 2017-11-10.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#import "../../../../Shaders/Effects/blend_header.metal"
#import "../../../../Shaders/Effects/place_header.metal"

/// Hardcoded. Also defined in Swift file.
constant int SPRITEMAX = 1024;

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    packed_float2 resolution;
    packed_float4 backgroundColor;
};

struct SpriteUniforms {
    int blendingMode;
    int placement;
    packed_float4 tint;
    packed_float2 position;
    packed_float2 size;
    float scale;
    float rotation;
    int horizontalAlignment;
    int verticalAlignment;
};

fragment float4 sprites(VertexOut out [[stage_in]],
                        texture2d_array<float> textures [[ texture(0) ]],
                        const device Uniforms& uniforms [[ buffer(0) ]],
                        const device array<SpriteUniforms, SPRITEMAX>& sprites [[ buffer(1) ]],
                        const device array<bool, SPRITEMAX>& activeSprites [[ buffer(2) ]],
                        sampler s [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    float2 resolution = uniforms.resolution;
    float aspectRatio = resolution.x / resolution.y;
    float2 aspectSize = float2(aspectRatio, 1.0);
    
    uint textureCount = textures.get_array_size();
    uint textureWidth = textures.get_width();
    uint textureHeight = textures.get_height();
    float textureAspectRatio = float(textureWidth) / float(textureHeight);
    float2 textureAspectSize = float2(textureAspectRatio, 1.0);
    
    uint spriteCount = 0;
    for (uint index = 0; index < SPRITEMAX; ++index) {
        if (!activeSprites[index]) {
            break;
        }
        spriteCount += 1;
    }
    
    uint count = max(textureCount, spriteCount);
    
    float4 colors = uniforms.backgroundColor;
    for (uint index = 0; index < count; ++index) {
        uint textureIndex = index % textureCount;
        uint spriteIndex = index % spriteCount;
        SpriteUniforms sprite = sprites[spriteIndex];
        float2 scale = sprite.size * sprite.scale * aspectSize / textureAspectSize;
        if (scale.x <= 0.0 || scale.y <= 0.0) {
            return 0.0;
        }
        float2 uvPlacement = transformPlace(sprite.placement,
                                            uv,
                                            resolution.x,
                                            resolution.y,
                                            textureWidth,
                                            textureHeight,
                                            sprite.position * aspectSize - aspectSize / 2,
                                            scale,
                                            sprite.rotation,
                                            sprite.horizontalAlignment,
                                            sprite.verticalAlignment);
        float4 sampleColor = textures.sample(s, uvPlacement, textureIndex);
        sampleColor *= float4(sprite.tint.rgb * sprite.tint.a, sprite.tint.a);
        colors = blend(sprite.blendingMode, colors, sampleColor);
    }
    
    return colors;
}

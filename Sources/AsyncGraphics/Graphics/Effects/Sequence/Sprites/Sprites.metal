//
//  Created by Anton Heestand on 2017-11-10.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#import "../../../../Shaders/Effects/blend_header.metal"

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    packed_float4 backgroundColor;
    uint count;
    packed_float2 samplingPadding;
};

struct SpriteTextureUniforms {
    uint index;
    uchar4 swizzle;
    uint hasTransparentBlackBorder;
};

struct SpriteUniforms {
    int blendingMode;
    SpriteTextureUniforms texture;
    uint transparentSampleIsIdentity;
    packed_float4 tint;
    packed_float2 center;
    packed_float2 xAxis;
    packed_float2 yAxis;
};

static float4 sampleSprite(texture2d<float> texture, sampler s, float2 uv, const device SpriteTextureUniforms&) {
    // Direct sampling already applies the source view's swizzle.
    return texture.sample(s, uv);
}

static float4 sampleSprite(texture2d_array<float> textures, sampler s, float2 uv, const device SpriteTextureUniforms& source) {
    float4 color = textures.sample(s, uv, source.index);
    // Blits copy stored channels. Restore the source view's MTLTextureSwizzle
    // selectors (zero, one, red, green, blue, alpha) on the sampled array slice.
    uchar4 swizzle = source.swizzle;
    if (all(swizzle == uchar4(2, 3, 4, 5))) { return color; }
    const float channels[6] = { 0.0, 1.0, color.r, color.g, color.b, color.a };
    return float4(channels[swizzle.r], channels[swizzle.g], channels[swizzle.b], channels[swizzle.a]);
}

template<typename Texture>
static float4 compositeSprites(VertexOut out, Texture textures, const device Uniforms& uniforms,
                               const device SpriteUniforms* sprites, sampler s) {
    float2 uv = out.texCoord - 0.5;
    float2 padding = uniforms.samplingPadding;
    float4 colors = uniforms.backgroundColor;
    for (uint index = 0; index < uniforms.count; ++index) {
        const device SpriteUniforms& sprite = sprites[index];
        float2 relativeUV = uv - float2(sprite.center);
        float2 uvPlacement = 0.5 + relativeUV.x * float2(sprite.xAxis) + relativeUV.y * float2(sprite.yAxis);
        bool outsideTransparentBorder = sprite.texture.hasTransparentBlackBorder &&
            (any(uvPlacement < -padding) || any(uvPlacement > 1.0 + padding));
        // Some blend modes still change the result when the sampled color is zero.
        if (outsideTransparentBorder && sprite.transparentSampleIsIdentity && colors.a >= 0.0) {
            continue;
        }
        float4 sampleColor = outsideTransparentBorder ? float4(0.0) : sampleSprite(textures, s, uvPlacement, sprite.texture);
        sampleColor *= float4(sprite.tint.rgb * sprite.tint.a, sprite.tint.a);
        colors = blend(sprite.blendingMode, colors, sampleColor);
    }
    
    return colors;
}

fragment float4 sprites(VertexOut out [[stage_in]],
                        texture2d_array<float> textures [[texture(0)]],
                        const device Uniforms& uniforms [[buffer(0)]],
                        const device SpriteUniforms* spriteBuffer [[buffer(1)]],
                        sampler s [[sampler(0)]]) {
    return compositeSprites(out, textures, uniforms, spriteBuffer, s);
}

fragment float4 spritesSingleTexture(VertexOut out [[stage_in]],
                                     texture2d<float> texture [[texture(0)]],
                                     const device Uniforms& uniforms [[buffer(0)]],
                                     const device SpriteUniforms* spriteBuffer [[buffer(1)]],
                                     sampler s [[sampler(0)]]) {
    return compositeSprites(out, texture, uniforms, spriteBuffer, s);
}

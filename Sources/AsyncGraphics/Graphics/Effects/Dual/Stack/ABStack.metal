//
//  Created by Anton Heestand on 2023-02-07.
//  Copyright © 2023 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    int axis;
    int alignment;
};

fragment float4 abStack(VertexOut out [[stage_in]],
                        texture2d<float> leadingTexture [[ texture(0) ]],
                        texture2d<float> trailingTexture [[ texture(1) ]],
                        const device Uniforms& uniforms [[ buffer(0) ]],
                        sampler sampler [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    
    float align = 0.0;
    switch (uniforms.alignment) {
        case -1: // top / leading
            align = 0.0;
            break;
        case 0: // center
            align = 0.5;
            break;
        case 1: // bottom / trailing
            align = 1.0;
            break;
    }
    
    uint leadingWidth = leadingTexture.get_width();
    uint leadingHeight = leadingTexture.get_height();
    uint trailingWidth = trailingTexture.get_width();
    uint trailingHeight = trailingTexture.get_height();
   
    float uvFraction = 0.0;
    float uvForward = 0.0;
    float uvSideways = 0.0;
    switch (uniforms.axis) {
        case 0: // horizontal
            uvFraction = float(leadingWidth) / float(leadingWidth + trailingWidth);
            uvForward = u;
            uvSideways = v;
            break;
        case 1: // vertical
            uvFraction = float(leadingHeight) / float(leadingHeight + trailingHeight);
            uvForward = v;
            uvSideways = u;
            break;
    }
    
    float4 color = 0.0;
    if (uvForward < uvFraction) {
        float2 uvLeading = 0.0;
        switch (uniforms.axis) {
            case 0: // horizontal
                uvLeading = float2(u / uvFraction, leadingHeight >= trailingHeight ? v : align - (align - v) / (float(leadingHeight) / float(trailingHeight)));
                break;
            case 1: // vertical
                uvLeading = float2(leadingWidth >= trailingWidth ? u : align - (align - u) / (float(leadingWidth) / float(trailingWidth)), v / uvFraction);
                break;
        }
        color = leadingTexture.sample(sampler, uvLeading);
    } else {
        float2 uvTrailing = 0.0;
        switch (uniforms.axis) {
            case 0: // horizontal
                uvTrailing = float2((u - uvFraction) / (1.0 - uvFraction), trailingHeight >= leadingHeight ? v : align - (align - v) / (float(trailingHeight) / float(leadingHeight)));
                break;
            case 1: // vertical
                uvTrailing = float2(trailingWidth >= leadingWidth ? u : align - (align - u) / (float(trailingWidth) / float(leadingWidth)), (v - uvFraction) / (1.0 - uvFraction));
                break;
        }
        color = trailingTexture.sample(sampler, uvTrailing);
    }
    
    return color;
}



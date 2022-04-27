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
    bool colored;
    bool transparent;
    bool includeAlpha;
    bool isSobel;
    float amplitude;
    float dist;
};

float monochromeEdge(texture2d<float> texture, sampler sampler, float4 c, float u, float v, uint width, uint height, float dist, float amplitude) {
    float4 cup = texture.sample(sampler, float2(u + dist / float(width), v));
    float4 cvp = texture.sample(sampler, float2(u, v + dist / float(height)));
    float4 cun = texture.sample(sampler, float2(u - dist / float(width), v));
    float4 cvn = texture.sample(sampler, float2(u, v - dist / float(height)));
    float cq = (c.r + c.g + c.b) / 3;
    float cupq = (cup.r + cup.g + cup.b) / 3;
    float cvpq = (cvp.r + cvp.g + cvp.b) / 3;
    float cunq = (cun.r + cun.g + cun.b) / 3;
    float cvnq = (cvn.r + cvn.g + cvn.b) / 3;
    float e = ((abs(cq - cupq) + abs(cq - cvpq) + abs(cq - cunq) + abs(cq - cvnq)) / 4) * amplitude;
    return e;
}

float colorEdge(texture2d<float> texture, sampler sampler, float c, float u, float v, uint width, uint height, float dist, float amplitude, int index) {
    float cup = texture.sample(sampler, float2(u + dist / float(width), v))[index];
    float cvp = texture.sample(sampler, float2(u, v + dist / float(height)))[index];
    float cun = texture.sample(sampler, float2(u - dist / float(width), v))[index];
    float cvn = texture.sample(sampler, float2(u, v - dist / float(height)))[index];
    float e = ((abs(c - cup) + abs(c - cvp) + abs(c - cun) + abs(c - cvn)) / 4) * amplitude;
    return e;
}

fragment float4 edge(VertexOut out [[stage_in]],
                     texture2d<float>  texture [[ texture(0) ]],
                     const device Uniforms& uniforms [[ buffer(0) ]],
                     sampler sampler [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    float4 color = texture.sample(sampler, uv);
    
    bool isSobel = uniforms.isSobel;
    if (isSobel) {
        return color;
    }
    
    uint width = texture.get_width();
    uint height = texture.get_height();
    
    bool isColored = uniforms.colored;
    bool isTransparent = uniforms.transparent;
    bool doseIncludeAlpha = uniforms.includeAlpha;
    
    float edge = monochromeEdge(texture, sampler, color, u, v, width, height, uniforms.dist, uniforms.amplitude);
    float edgeAlpha = 0;
    if (doseIncludeAlpha) {
        edgeAlpha = colorEdge(texture, sampler, color.a, u, v, width, height, uniforms.dist, uniforms.amplitude, 3);
        edge += edgeAlpha;
    }
    
    float4 edgeColor = 0;
    if (!isColored) {
        edgeColor = float4(edge, edge, edge, isTransparent ? edge : 1.0);
    } else {
        float edgeRed = colorEdge(texture, sampler, color.r, u, v, width, height, uniforms.dist, uniforms.amplitude, 0);
        float edgeGreen = colorEdge(texture, sampler, color.g, u, v, width, height, uniforms.dist, uniforms.amplitude, 1);
        float edgeBlue = colorEdge(texture, sampler, color.b, u, v, width, height, uniforms.dist, uniforms.amplitude, 2);
        edgeColor = float4(edgeRed, edgeGreen, edgeBlue, isTransparent ? (doseIncludeAlpha ? edgeAlpha : edge) : 1.0);
    }
    
    return edgeColor;
}



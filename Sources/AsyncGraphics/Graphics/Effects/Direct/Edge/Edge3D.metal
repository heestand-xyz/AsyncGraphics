//
//  Created by Anton Heestand on 2017-11-21.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct Uniforms {
    bool colored;
    bool transparent;
    bool includeAlpha;
    float amplitude;
    float dist;
};

float monochromeEdge(texture3d<float> texture, sampler sampler, float4 c, float u, float v, float w, uint width, uint height, uint depth, float dist, float amplitude) {
    float4 cup = texture.sample(sampler, float3(u + dist / float(width), v, w));
    float4 cvp = texture.sample(sampler, float3(u, v + dist / float(height), w));
    float4 cwp = texture.sample(sampler, float3(u, v, w + dist / float(depth)));
    float4 cun = texture.sample(sampler, float3(u - dist / float(width), v, w));
    float4 cvn = texture.sample(sampler, float3(u, v - dist / float(height), w));
    float4 cwn = texture.sample(sampler, float3(u, v, w - dist / float(depth)));
    float cq = (c.r + c.g + c.b) / 3;
    float cupq = (cup.r + cup.g + cup.b) / 3;
    float cvpq = (cvp.r + cvp.g + cvp.b) / 3;
    float cwpq = (cwp.r + cwp.g + cwp.b) / 3;
    float cunq = (cun.r + cun.g + cun.b) / 3;
    float cvnq = (cvn.r + cvn.g + cvn.b) / 3;
    float cwnq = (cwn.r + cwn.g + cwn.b) / 3;
    float e = ((abs(cq - cupq) + abs(cq - cvpq) + abs(cq - cwpq) + abs(cq - cunq) + abs(cq - cvnq) + abs(cq - cwnq)) / 6) * amplitude;
    return e;
}

float colorEdge(texture3d<float> texture, sampler sampler, float c, float u, float v, float w, uint width, uint height, uint depth, float dist, float amplitude, int index) {
    float cup = texture.sample(sampler, float3(u + dist / float(width), v, w))[index];
    float cvp = texture.sample(sampler, float3(u, v + dist / float(height), w))[index];
    float cwp = texture.sample(sampler, float3(u, v, w + dist / float(depth)))[index];
    float cun = texture.sample(sampler, float3(u - dist / float(width), v, w))[index];
    float cvn = texture.sample(sampler, float3(u, v - dist / float(height), w))[index];
    float cwn = texture.sample(sampler, float3(u, v, w - dist / float(depth)))[index];
    float e = ((abs(c - cup) + abs(c - cvp) + abs(c - cwp) + abs(c - cun) + abs(c - cvn) + abs(c - cwn)) / 6) * amplitude;
    return e;
}

kernel void edge3d(const device Uniforms& uniforms [[ buffer(0) ]],
                   texture3d<float, access::write>  targetTexture [[ texture(0) ]],
                   texture3d<float, access::sample> texture [[ texture(1) ]],
                   uint3 pos [[ thread_position_in_grid ]],
                   sampler sampler [[ sampler(0) ]]) {
    
    uint width = targetTexture.get_width();
    uint height = targetTexture.get_height();
    uint depth = targetTexture.get_depth();
    
    if (pos.x >= width || pos.y >= height || pos.z >= depth) {
        return;
    }
    
    float u = float(pos.x + 0.5) / float(width);
    float v = float(pos.y + 0.5) / float(height);
    float w = float(pos.z + 0.5) / float(depth);
    float3 uvw = float3(u, v, w);
    
    float4 color = texture.sample(sampler, uvw);
    
    bool isColored = uniforms.colored;
    bool isTransparent = uniforms.transparent;
    bool doseIncludeAlpha = uniforms.includeAlpha;
    
    float edge = monochromeEdge(texture, sampler, color, u, v, w, width, height, depth, uniforms.dist, uniforms.amplitude);
    float edgeAlpha = 0;
    if (doseIncludeAlpha) {
        edgeAlpha = colorEdge(texture, sampler, color.a, u, v, w, width, height, depth, uniforms.dist, uniforms.amplitude, 3);
        edge += edgeAlpha;
    }
    
    float4 edgeColor = 0;
    if (!isColored) {
        edgeColor = float4(edge, edge, edge, isTransparent ? edge : 1.0);
    } else {
        float edgeRed = colorEdge(texture, sampler, color.r, u, v, w, width, height, depth, uniforms.dist, uniforms.amplitude, 0);
        float edgeGreen = colorEdge(texture, sampler, color.g, u, v, w, width, height, depth, uniforms.dist, uniforms.amplitude, 1);
        float edgeBlue = colorEdge(texture, sampler, color.b, u, v, w, width, height, depth, uniforms.dist, uniforms.amplitude, 2);
        edgeColor = float4(edgeRed, edgeGreen, edgeBlue, isTransparent ? (doseIncludeAlpha ? edgeAlpha : edge) : 1.0);
    }
    
    targetTexture.write(edgeColor, pos);
}



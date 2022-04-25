//
//  Created by Anton Heestand on 2020-06-01.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    int axis;
    packed_int3 alignment;
    float spacing;
    float padding;
    packed_float4 backgroundColor;
    packed_float3 resolution;
};

kernel void stack3d(const device Uniforms& uniforms [[ buffer(0) ]],
                    texture3d<float, access::write> targetTexture [[ texture(0) ]],
                    texture3d<float, access::sample> leadingTexture [[ texture(1) ]],
                    texture3d<float, access::sample> trailingTexture [[ texture(2) ]],
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
    targetTexture.write(float4(u, v, w, 1.0), pos);
    return;

    int axis = uniforms.axis;
    int3 alignment = uniforms.alignment;
    float spacing = min(max(uniforms.spacing, 0.0), 1.0);
    float padding = min(max(uniforms.padding, 0.0), 1.0);
    float4 backgroundColor = float4(uniforms.backgroundColor.rgb * uniforms.backgroundColor.a, uniforms.backgroundColor.a);
    
    int count = 2;
    
    float sizeFraction = 1.0;
    sizeFraction -= float(count - 1) * spacing;
    sizeFraction -= padding * 2;
    sizeFraction /= float(count);
    
    bool isHorizontal = axis == 0;
    bool isVertical = axis == 1;
    bool isDepth = axis == 2;

    float fullAspect = uniforms.resolution.x / uniforms.resolution.y;
    float fullDepthAspect = uniforms.resolution.z / uniforms.resolution.y;
    float relativeFullAspect = isVertical ? fullAspect : (1.0 / fullAspect);
    float relativeFullDepthAspect = isVertical ? fullDepthAspect : (1.0 / fullDepthAspect);
    
    float4 color = backgroundColor;
    float offset = padding;
    for (uint i = 0; i < count; i++) {
        
        float fullCoordinate = isHorizontal ? u : isVertical ? v : w;
        float coordinate = (fullCoordinate - offset) / sizeFraction;
        offset += sizeFraction + spacing;
        if (coordinate < 0.0 || coordinate > 1.0) { continue; }
        
        texture3d<float> iTexture = i == 0 ? leadingTexture : trailingTexture;
        float width = float(iTexture.get_width());
        float height = float(iTexture.get_height());
        float depth = float(iTexture.get_depth());
        float aspect = width / height;
        float depthAspect = depth / height;
        float relativeAspect = isVertical ? aspect : (1.0 / aspect);
        float relativeDepthAspect = isVertical ? depthAspect : (1.0 / depthAspect);
        float tangentSizeFraction = (sizeFraction * relativeAspect) / relativeFullAspect;
        if (isDepth) {
            tangentSizeFraction /= relativeFullDepthAspect;
        }
        float tangentDepthSizeFraction = (sizeFraction * relativeDepthAspect) / relativeFullDepthAspect;
        if (isHorizontal) {
            tangentDepthSizeFraction /= relativeFullAspect;
        }

        float fullTangentCoordinate = isHorizontal ? v : u;
        float tangentCoordinate = 0.0;
        int iAlignment = isHorizontal ? alignment.y : alignment.x;
        switch (iAlignment) {
            case -1: // leading: left or bottom or near
                tangentCoordinate = fullTangentCoordinate / tangentSizeFraction;
                break;
            case 0: // center
                tangentCoordinate = 0.5 + (fullTangentCoordinate - 0.5) / tangentSizeFraction;
                break;
            case 1: // trailing: right or top or far
                tangentCoordinate = 1.0 + (fullTangentCoordinate - 1.0) / tangentSizeFraction;
                break;
        }
        
        if (tangentCoordinate < 0.0 || tangentCoordinate > 1.0) { continue; }
        
        float fullTangentDepthCoordinate = isDepth ? v : w;
        float tangentDepthCoordinate = 0.0;
        int iDepthAlignment = isDepth ? alignment.y : alignment.z;
        switch (iDepthAlignment) {
            case -1: // leading: left or bottom or near
                tangentDepthCoordinate = fullTangentDepthCoordinate / tangentDepthSizeFraction;
                break;
            case 0: // center
                tangentDepthCoordinate = 0.5 + (fullTangentDepthCoordinate - 0.5) / tangentDepthSizeFraction;
                break;
            case 1: // trailing: right or top or far
                tangentDepthCoordinate = 1.0 + (fullTangentDepthCoordinate - 1.0) / tangentDepthSizeFraction;
                break;
        }
        
        if (tangentDepthCoordinate < 0.0 || tangentDepthCoordinate > 1.0) { continue; }
        
        float iu = isHorizontal ? coordinate : tangentCoordinate;
        float iv = isVertical ? coordinate : isHorizontal ? tangentCoordinate : tangentDepthCoordinate;
        float iw = isDepth ? coordinate : tangentDepthCoordinate;
        float3 iuvw = float3(iu, iv, iw);
        
        float4 iColor = iTexture.sample(sampler, iuvw);
        color = float4(float3(color) * (1.0 - iColor.a) + float3(iColor), max(color.a, iColor.a));
        
    }
    
    targetTexture.write(color, pos);
}

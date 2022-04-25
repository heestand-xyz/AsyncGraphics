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
    int alignment;
    float spacing;
    float padding;
    packed_float4 backgroundColor;
    packed_float2 resolution;
};

fragment float4 stack(VertexOut out [[stage_in]],
                      texture2d_array<float> textures [[ texture(0) ]],
                      const device Uniforms& uniforms [[ buffer(0) ]],
                      sampler sampler [[ sampler(0) ]]) {

    float u = out.texCoord[0];
    float v = out.texCoord[1];

    int axis = uniforms.axis;
    int alignment = uniforms.alignment;
    float spacing = min(max(uniforms.spacing, 0.0), 1.0);
    float padding = min(max(uniforms.padding, 0.0), 1.0);
    float4 backgroundColor = float4(uniforms.backgroundColor.rgb * uniforms.backgroundColor.a, uniforms.backgroundColor.a);

    uint count = textures.get_array_size();
    if (count == 0) {
        return backgroundColor;
    }

    float sizeFraction = 1.0;
    sizeFraction -= float(count - 1) * spacing;
    sizeFraction -= padding * 2;
    sizeFraction /= float(count);

    bool isHorizontal = axis == 0;
    bool isVertical = axis == 1;

    float fullAspect = uniforms.resolution.x / uniforms.resolution.y;
    float relativeFullAspect = isVertical ? fullAspect : (1.0 / fullAspect);

    float4 color = backgroundColor;
    float offset = padding;
    for (uint i = 0; i < count; i++) {

        float fullCoordinate = isVertical ? v : u;
        float coordinate = (fullCoordinate - offset) / sizeFraction;
        offset += sizeFraction + spacing;
        if (coordinate < 0.0 || coordinate > 1.0) { continue; }

        float width = float(textures.get_width());
        float height = float(textures.get_height());
        float aspect = width / height;
        float relativeAspect = isVertical ? aspect : (1.0 / aspect);
        float tangentSizeFraction = (sizeFraction * relativeAspect) / relativeFullAspect;

        float fullTangentCoordinate = isVertical ? u : v;
        float tangentCoordinate = 0.0;
        switch (alignment) {
            case -1: // leading: left or bottom
                tangentCoordinate = fullTangentCoordinate / tangentSizeFraction;
                break;
            case 0: // center
                tangentCoordinate = 0.5 + (fullTangentCoordinate - 0.5) / tangentSizeFraction;
                break;
            case 1: // trailing: right or top
                tangentCoordinate = 1.0 + (fullTangentCoordinate - 1.0) / tangentSizeFraction;
                break;
        }
        if (tangentCoordinate < 0.0 || tangentCoordinate > 1.0) { continue; }

        float iu = isHorizontal ? coordinate : tangentCoordinate;
        float iv = isVertical ? coordinate : tangentCoordinate;
        float2 iuv = float2(iu, iv);

        float4 iColor = textures.sample(sampler, iuv, i);
        color = float4(float3(color) * (1.0 - iColor.a) + float3(iColor), max(color.a, iColor.a));

    }

    return color;
}

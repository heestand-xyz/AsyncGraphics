//
//  Created by Anton Heestand on 2023-07-05.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    int count;
};

fragment float4 lut(VertexOut out [[stage_in]],
                    texture2d<float> leadingTexture [[ texture(0) ]],
                    texture2d<float> trailingTexture [[ texture(1) ]],
                    const device Uniforms& uniforms [[ buffer(0) ]],
                    sampler sampler [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    float4 sourceColor = leadingTexture.sample(sampler, uv);
    
    int count = uniforms.count;
    int powerCount = count * count;
    int resCount = count * count * count;
    
    float x = sourceColor.x * (powerCount - 1);
    int xLow = int(floor(x));
    int xHigh = int(ceil(x));
    float xFraction = x - xLow;
    
    float y = sourceColor.y * (powerCount - 1);
    int yLow = int(floor(y));
    int yHigh = int(ceil(y));
    float yFraction = y - yLow;

    float z = sourceColor.z * (powerCount - 1);
    int zIndexLow = int(floor(z));
    int zIndexHigh = int(ceil(z));
    int2 zLow = int2(zIndexLow % count, zIndexLow / count);
    int2 zHigh = int2(zIndexHigh % count, zIndexHigh / count);
    float zFraction = z - zIndexLow;
    
    float2 xLow_yLow_zLow = float2(zLow) / count + float2(xLow, yLow) / resCount;
    float2 xLow_yLow_zHigh = float2(zHigh) / count + float2(xLow, yLow) / resCount;
    float2 xLow_yHigh_zLow = float2(zLow) / count + float2(xLow, yHigh) / resCount;
    float2 xLow_yHigh_zHigh = float2(zHigh) / count + float2(xLow, yHigh) / resCount;
    float2 xHigh_yLow_zLow = float2(zLow) / count + float2(xHigh, yLow) / resCount;
    float2 xHigh_yLow_zHigh = float2(zHigh) / count + float2(xHigh, yLow) / resCount;
    float2 xHigh_yHigh_zLow = float2(zLow) / count + float2(xHigh, yHigh) / resCount;
    float2 xHigh_yHigh_zHigh = float2(zHigh) / count + float2(xHigh, yHigh) / resCount;
    
    float4 xLow_yLow_zLow_color = trailingTexture.sample(sampler, xLow_yLow_zLow);
    float4 xLow_yLow_zHigh_color = trailingTexture.sample(sampler, xLow_yLow_zHigh);
    float4 xLow_yHigh_zLow_color = trailingTexture.sample(sampler, xLow_yHigh_zLow);
    float4 xLow_yHigh_zHigh_color = trailingTexture.sample(sampler, xLow_yHigh_zHigh);
    float4 xHigh_yLow_zLow_color = trailingTexture.sample(sampler, xHigh_yLow_zLow);
    float4 xHigh_yLow_zHigh_color = trailingTexture.sample(sampler, xHigh_yLow_zHigh);
    float4 xHigh_yHigh_zLow_color = trailingTexture.sample(sampler, xHigh_yHigh_zLow);
    float4 xHigh_yHigh_zHigh_color = trailingTexture.sample(sampler, xHigh_yHigh_zHigh);
    
    float4 xLow_yLow_color = mix(xLow_yLow_zLow_color, xLow_yLow_zHigh_color, zFraction);
    float4 xLow_yHigh_color = mix(xLow_yHigh_zLow_color, xLow_yHigh_zHigh_color, zFraction);
    float4 xHigh_yLow_color = mix(xHigh_yLow_zLow_color, xHigh_yLow_zHigh_color, zFraction);
    float4 xHigh_yHigh_color = mix(xHigh_yHigh_zLow_color, xHigh_yHigh_zHigh_color, zFraction);
    float4 xLow_color = mix(xLow_yLow_color, xLow_yHigh_color, yFraction);
    float4 xHigh_color = mix(xHigh_yLow_color, xHigh_yHigh_color, yFraction);
    float4 color = mix(xLow_color, xHigh_color, xFraction);
    
    return color;
}

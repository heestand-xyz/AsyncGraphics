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

fragment float4 lutSquare(VertexOut out [[stage_in]],
                          texture2d<float> leadingTexture [[ texture(0) ]],
                          texture2d<float> trailingTexture [[ texture(1) ]],
                          const device Uniforms& uniforms [[ buffer(0) ]],
                          sampler sampler [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    float4 sourceColor = leadingTexture.sample(sampler, uv);
    
    int count = uniforms.count;
    int squareCount = count * count;
    int cubeCount = count * count * count;
    
    float x = sourceColor.x * (squareCount - 1);
    int xLow = int(floor(x));
    int xHigh = int(ceil(x));
    float xFraction = x - xLow;
    
    float y = sourceColor.y * (squareCount - 1);
    int yLow = int(floor(y));
    int yHigh = int(ceil(y));
    float yFraction = y - yLow;

    float z = sourceColor.z * (squareCount - 1);
    int zIndexLow = int(floor(z));
    int zIndexHigh = int(ceil(z));
    int2 zLow = int2(zIndexLow % count, zIndexLow / count);
    int2 zHigh = int2(zIndexHigh % count, zIndexHigh / count);
    float zFraction = z - zIndexLow;
    
    float2 xLow_yLow_zLow = float2(zLow) / count + float2(xLow, yLow) / cubeCount;
    float2 xLow_yLow_zHigh = float2(zHigh) / count + float2(xLow, yLow) / cubeCount;
    float2 xLow_yHigh_zLow = float2(zLow) / count + float2(xLow, yHigh) / cubeCount;
    float2 xLow_yHigh_zHigh = float2(zHigh) / count + float2(xLow, yHigh) / cubeCount;
    float2 xHigh_yLow_zLow = float2(zLow) / count + float2(xHigh, yLow) / cubeCount;
    float2 xHigh_yLow_zHigh = float2(zHigh) / count + float2(xHigh, yLow) / cubeCount;
    float2 xHigh_yHigh_zLow = float2(zLow) / count + float2(xHigh, yHigh) / cubeCount;
    float2 xHigh_yHigh_zHigh = float2(zHigh) / count + float2(xHigh, yHigh) / cubeCount;
    
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

fragment float4 lutLinear(VertexOut out [[stage_in]],
                          texture2d<float> leadingTexture [[ texture(0) ]],
                          texture2d<float> trailingTexture [[ texture(1) ]],
                          const device Uniforms& uniforms [[ buffer(0) ]],
                          sampler sampler [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    float4 sourceColor = leadingTexture.sample(sampler, uv);
    
    int count = uniforms.count;
    int2 linearCount = int2(count * count, count);
    
    float x = sourceColor.x * (count - 1);
    int xLow = int(floor(x));
    int xHigh = int(ceil(x));
    float xFraction = x - xLow;
    
    float y = sourceColor.y * (count - 1);
    int yLow = int(floor(y));
    int yHigh = int(ceil(y));
    float yFraction = y - yLow;

    float z = sourceColor.z * (count - 1);
    int zLow = int(floor(z));
    int zHigh = int(ceil(z));
    float zFraction = z - zLow;
    
    float2 xLow_yLow_zLow = float2(zLow, 0.0) / count + float2(float(xLow) / linearCount.x, float(yLow) / linearCount.y);
    float2 xLow_yLow_zHigh = float2(zHigh, 0.0) / count + float2(float(xLow) / linearCount.x, float(yLow) / linearCount.y);
    float2 xLow_yHigh_zLow = float2(zLow, 0.0) / count + float2(float(xLow) / linearCount.x, float(yHigh) / linearCount.y);
    float2 xLow_yHigh_zHigh = float2(zHigh, 0.0) / count + float2(float(xLow) / linearCount.x, float(yHigh) / linearCount.y);
    float2 xHigh_yLow_zLow = float2(zLow, 0.0) / count + float2(float(xHigh) / linearCount.x, float(yLow) / linearCount.y);
    float2 xHigh_yLow_zHigh = float2(zHigh, 0.0) / count + float2(float(xHigh) / linearCount.x, float(yLow) / linearCount.y);
    float2 xHigh_yHigh_zLow = float2(zLow, 0.0) / count + float2(float(xHigh) / linearCount.x, float(yHigh) / linearCount.y);
    float2 xHigh_yHigh_zHigh = float2(zHigh, 0.0) / count + float2(float(xHigh) / linearCount.x, float(yHigh) / linearCount.y);
    
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

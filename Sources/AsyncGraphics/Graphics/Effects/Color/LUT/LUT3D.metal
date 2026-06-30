//
//  LUT3D.metal
//  AsyncGraphics
//
//  Created by Anton Heestand on 2026-06-30.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    int size;
    uint layout; // 0 = square, 1 = linear
};

// MARK: - 2D to 3D

// Maps a 2D LUT (square or linear layout) into a 3D color cube.
// Each voxel position maps to a color index (red, green, blue).
kernel void lut2dTo3d(const device Uniforms& uniforms [[ buffer(0) ]],
                  texture3d<float, access::write> targetTexture [[ texture(0) ]],
                  texture2d<float, access::sample> lutTexture [[ texture(1) ]],
                  uint3 pos [[ thread_position_in_grid ]],
                  sampler s [[ sampler(0) ]]) {

    uint width = targetTexture.get_width();
    uint height = targetTexture.get_height();
    uint depth = targetTexture.get_depth();

    if (pos.x >= width || pos.y >= height || pos.z >= depth) {
        return;
    }

    int size = uniforms.size;
    int red = int(pos.x);
    int green = int(pos.y);
    int blue = int(pos.z);

    float2 uv;
    if (uniforms.layout == 0) {
        // Square
        int blockCount = int(round(sqrt(float(size))));
        int squareWidth = blockCount * size;
        int tileX = blue % blockCount;
        int tileY = blue / blockCount;
        float x = float(tileX * size + red) + 0.5;
        float y = float(tileY * size + green) + 0.5;
        uv = float2(x / float(squareWidth), y / float(squareWidth));
    } else {
        // Linear
        int linearWidth = size * size;
        float x = float(blue * size + red) + 0.5;
        float y = float(green) + 0.5;
        uv = float2(x / float(linearWidth), y / float(size));
    }

    float4 color = lutTexture.sample(s, uv);

    targetTexture.write(color, pos);
}

// MARK: - 3D to 2D

// Maps a 3D color cube back into a 2D LUT (square or linear layout).
fragment float4 lut3dTo2d(VertexOut out [[stage_in]],
                          texture3d<float> texture [[ texture(0) ]],
                          const device Uniforms& uniforms [[ buffer(0) ]],
                          sampler s [[ sampler(0) ]]) {

    float u = out.texCoord[0];
    float v = out.texCoord[1];

    int size = uniforms.size;

    int red;
    int green;
    int blue;
    if (uniforms.layout == 0) {
        // Square
        int blockCount = int(round(sqrt(float(size))));
        int squareWidth = blockCount * size;
        int x = clamp(int(floor(u * float(squareWidth))), 0, squareWidth - 1);
        int y = clamp(int(floor(v * float(squareWidth))), 0, squareWidth - 1);
        red = x % size;
        green = y % size;
        blue = (y / size) * blockCount + (x / size);
    } else {
        // Linear
        int linearWidth = size * size;
        int x = clamp(int(floor(u * float(linearWidth))), 0, linearWidth - 1);
        int y = clamp(int(floor(v * float(size))), 0, size - 1);
        red = x % size;
        green = y;
        blue = x / size;
    }

    float3 crd = float3((float(red) + 0.5) / float(size),
                        (float(green) + 0.5) / float(size),
                        (float(blue) + 0.5) / float(size));

    return texture.sample(s, crd);
}

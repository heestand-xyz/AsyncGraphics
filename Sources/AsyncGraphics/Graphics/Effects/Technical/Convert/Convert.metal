//
//  Convert.metal
//  AsyncGraphics
//
//  Created by Anton Heestand on 2019-04-25.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    uint mode;
    float rx;
    float ry;
    float fraction;
};

float2 domeToEqui(float2 uv) {
    float pi = M_PI_F;
    float rad = uv.y;
    float ang = uv.x * pi * 2;
    return float2(0.5 + cos(ang) * rad, 0.5 - sin(ang) * rad);
}

float2 equiToDome(float2 uv, float rx, float ry) {
    float pi = M_PI_F;
    float rad = sqrt(pow(uv.x - 0.5, 2) + pow(uv.y - 0.5, 2)) / 2 + 0.25;
    float ang = 1.0 - (atan2(uv.y - 0.5, uv.x - 0.5) / (pi * 2) + 0.25);
    if (ang > 1) {
        ang -= 1;
    }
    return float2(ang, rad);
}

// https://stackoverflow.com/a/32391780
float2 squareToCircle(float2 uv) {
    float u = uv.x * 2 - 1;
    float v = uv.y * 2 - 1;
    float x1 = 0.5 * sqrt(max(2.0 + pow(u, 2.0) - pow(v, 2.0) + 2.0 * u * sqrt(2.0), 0.0));
    float x2 = 0.5 * sqrt(max(2.0 + pow(u, 2.0) - pow(v, 2.0) - 2.0 * u * sqrt(2.0), 0.0));
    float x = x1 - x2;
    float y1 = 0.5 * sqrt(max(2.0 - pow(u, 2.0) + pow(v, 2.0) + 2.0 * v * sqrt(2.0), 0.0));
    float y2 = 0.5 * sqrt(max(2.0 - pow(u, 2.0) + pow(v, 2.0) - 2.0 * v * sqrt(2.0), 0.0));
    float y = y1 - y2;
    return float2(x, y) / 2 + 0.5;
}
float2 circleToSquare(float2 uv) {
    float u = uv.x * 2 - 1;
    float v = uv.y * 2 - 1;
    float x = u * sqrt(1 - 0.5 * pow(v, 2));
    float y = v * sqrt(1 - 0.5 * pow(u, 2));
    return float2(x, y) / 2 + 0.5;
}

float2 cubeToEqui(float2 uv) {
    float pi = M_PI_F;
    float theta = uv.x * pi * 2;
    float phi = ((1.0 - uv.y) * pi) + pi / 2;
    float x = cos(phi) * sin(theta);
    float y = sin(phi);
    float z = cos(phi) * cos(theta);
    float scale;
    float2 px;
    if (abs(x) >= abs(y) && abs(x) >= abs(z)) {
        if (x < 0.0) { // Left
            scale = -1.0 / x;
            px.x = ( z*scale + 1.0) / 2.0;
            px.y = ( y*scale + 1.0) / 2.0;
            uv = float2(px.x / 4, (px.y + 1) / 3 + 1 / 3);
        }
        else { // Right
            scale = 1.0 / x;
            px.x = (-z*scale + 1.0) / 2.0;
            px.y = ( y*scale + 1.0) / 2.0;
            uv = float2((px.x + 2) / 4 + 2 / 4, (px.y + 1) / 3 + 1 / 3);
        }
    }
    else if (abs(y) >= abs(z)) {
        if (y < 0.0) { // Top
            scale = -1.0 / y;
            px.x = ( x*scale + 1.0) / 2.0;
            px.y = ( z*scale + 1.0) / 2.0;
            uv = float2((px.x + 1) / 4 + 1 / 4, px.y / 3 + 2 / 3);
        }
        else { // Bottom
            scale = 1.0 / y;
            px.x = ( x*scale + 1.0) / 2.0;
            px.y = (-z*scale + 1.0) / 2.0;
            uv = float2((px.x + 1) / 4 + 1 / 4, (px.y + 2) / 3);
        }
    }
    else {
        if (z < 0.0) { // Back
            scale = -1.0 / z;
            px.x = (-x*scale + 1.0) / 2.0;
            px.y = ( y*scale + 1.0) / 2.0;
            uv = float2((px.x + 3) / 4 + 3 / 4, (px.y + 1) / 3 + 1 / 3);
        }
        else { // Front
            scale = 1.0 / z;
            px.x = ( x*scale + 1.0) / 2.0;
            px.y = ( y*scale + 1.0) / 2.0;
            uv = float2((px.x + 1) / 4 + 1 / 4, (px.y + 1) / 3 + 1 / 3);
        }
    }
    return uv;
}

fragment float4 convert(VertexOut out [[stage_in]],
                        texture2d<float> texture [[ texture(0) ]],
                        const device Uniforms& uniforms [[ buffer(0) ]],
                        sampler sampler [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    float2 displaceUV = uv;
    switch (int(uniforms.mode)) {
        case 0: // domeToEqui
            displaceUV = domeToEqui(uv);
            break;
        case 1: // equiToDome
            displaceUV = equiToDome(uv, uniforms.rx, uniforms.ry);
            break;
        case 2: // cubeToEqui
            displaceUV = cubeToEqui(uv);
            break;
        case 4: // squareToCircle
            displaceUV = squareToCircle(uv);
            break;
        case 5: // circleToSquare
            displaceUV = circleToSquare(uv);
            break;
    }
    
    float2 fractionUV = uv * (1.0 - uniforms.fraction) + displaceUV * uniforms.fraction;
    
    float4 color = texture.sample(sampler, fractionUV);
    
    switch (int(uniforms.mode)) {
        case 0: // domeToEqui
            if (v > 0.5) {
                color = 0;
            }
            break;
        case 1: // equiToDome
            if (sqrt(pow(u - 0.5, 2) + pow(v - 0.5, 2)) > 0.5) {
                color = 0;
            }
            break;
    }
    
    return color;
}

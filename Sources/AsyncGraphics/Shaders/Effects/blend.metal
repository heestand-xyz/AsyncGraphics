//
//  blend.metal
//  PixelKitShaders
//
//  Created by Anton Heestand on 2019-10-07.
//  Copyright © 2019 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#include "blend_header.metal"

float lerp(float fraction, float leading, float trailing) {
    return leading * (1.0 - fraction) + trailing * fraction;
}

float3 lerpColor(float3 fraction, float3 leading, float3 trailing) {
    return leading * (1.0 - fraction) + trailing * fraction;
}

float4 lerpColor(float4 fraction, float4 leading, float4 trailing) {
    return leading * (1.0 - fraction) + trailing * fraction;
}

float4 blendOver(float4 leading, float4 trailing) {
    return blend(0, leading, trailing);
}

float4 blend(int mode, float4 leading, float4 trailing) {
    
    float pi = M_PI_F;

    float maxAlpha = max(leading.a, trailing.a);
    float minAlpha = min(leading.a, trailing.a);
    float subtractionAlpha = leading.a - trailing.a;
    float differenceAlpha = abs(subtractionAlpha);
//    float intersectionAlpha = lerp(maxAlpha, 0.0, minAlpha);
    
    float4 color;
    switch (mode) {
        case 0: // Over
            color = float4(leading.rgb * (1.0 - trailing.a) + trailing.rgb * trailing.a, maxAlpha);
            break;
        case 25: // Over with Alpha
//            color = float4(float3(intersectionAlpha), 0.1);
            color = float4(leading.rgb * (1.0 - trailing.a) + trailing.rgb, maxAlpha);
            break;
        case 1: // Under
            color = float4(leading.rgb * leading.a + trailing.rgb * (1.0 - leading.a), maxAlpha);
            break;
        case 18: // Screen
            color = float4(1.0 - (1.0 - leading.rgb) * (1.0 - trailing.rgb), maxAlpha);
            break;
        case 19: // Lighten
            color = float4(max(leading.rgb, trailing.rgb), maxAlpha);
            break;
        case 20: // Darken
            color = float4(min(leading.rgb, trailing.rgb), maxAlpha);
            break;
        case 21: // Darken without Alpha
            color = float4(lerpColor(minAlpha,
                                 max(leading.rgb, trailing.rgb),
                                 min(leading.rgb, trailing.rgb)), maxAlpha);
            break;
        case 2: // Add
            color = float4(leading.rgb + trailing.rgb, maxAlpha);
            break;
        case 3: // Add with Alpha
            color = leading + trailing;
            break;
        case 4: // Multiply
            color = leading * trailing;
            break;
//        case 22: // Multiply with Alpha
//            color = float4(lerpColor(minAlpha, max(leading.rgb, trailing.rgb),
//                                 leading.rgb * trailing.rgb), maxAlpha);
//            break;
        case 23: // Multiply without Alpha
            color = float4(lerpColor(minAlpha, max(leading.rgb, trailing.rgb),
                                 leading.rgb * trailing.rgb), maxAlpha);
            break;
        case 5: // Diff
            color = float4(abs(leading.rgb - trailing.rgb), maxAlpha);
            break;
        case 24: // Diff with Alpha
            color = float4(float3(abs(abs(leading.rgb - trailing.rgb) - abs(leading.a - trailing.a))), maxAlpha);
            break;
        case 6: // Sub
            color = float4(leading.rgb - trailing.rgb, maxAlpha);
            break;
        case 7: // Sub with Alpha
            color = leading - trailing;
            break;
        case 8: // Max
            color = max(leading, trailing);
            break;
        case 9: // Min
            color = min(leading, trailing);
            break;
        case 10: // Gamma
            color = pow(leading, 1 / trailing);
            break;
        case 11: // Power
            color = pow(leading, trailing);
            break;
        case 12: // Divide
            color = leading / trailing;
            break;
        case 13: // Average
            color = leading / 2 + trailing / 2;
            break;
        case 14: // Cosine
            color = lerpColor(min(trailing.r, 1.0), leading, cos(leading * pi + pi) / 2 + 0.5);
            for (int i = 1; i < int(ceil(trailing.r)); i++) {
                color = lerpColor(min(max(trailing.r - float(i), 0.0), 1.0), color, cos(color * pi + pi) / 2 + 0.5);
            }
            break;
        case 15: // Inside Source
            color = float4(leading.rgb * minAlpha, minAlpha);
            break;
//        case 15: // Inside Destination
//            color = float4(trailing.rgb * minAlpha, minAlpha);
//            break;
        case 16: // Outside Source
            color = float4(leading.rgb * subtractionAlpha, subtractionAlpha);
            break;
//        case 17: // Outside Destination
//            color = float4(trailing.rgb * subtractionAlpha, subtractionAlpha);
//            break;
        case 17: // XOR
            color = float4(leading.rgb * (leading.a * differenceAlpha) + trailing.rgb * (trailing.a * differenceAlpha), differenceAlpha);
            break;
    }
    
    return color;
}
